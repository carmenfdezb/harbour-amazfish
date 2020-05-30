#include "activityfetchoperation.h"

#include <QDebug>
#include <KDb3/KDbTransactionGuard>

#include "mibandservice.h"
#include "typeconversion.h"
#include "amazfishconfig.h"

ActivityFetchOperation::ActivityFetchOperation(QBLEService *service, KDbConnection *conn) : AbstractFetchOperation(service)
{
    m_conn = conn;
    setLastSyncKey("device/lastactivitysyncmillis");
}

void ActivityFetchOperation::start()
{
    setStartDate(lastActivitySync());


    qDebug() << "last activity sync was" << startDate();

    QByteArray rawDate = TypeConversion::dateTimeToBytes(startDate(), 0, false);

    m_service->enableNotification(MiBandService::UUID_CHARACTERISTIC_MIBAND_ACTIVITY_DATA);
    m_service->enableNotification(MiBandService::UUID_CHARACTERISTIC_MIBAND_FETCH_DATA);

    //Send log read configuration
    m_service->writeValue(MiBandService::UUID_CHARACTERISTIC_MIBAND_FETCH_DATA, QByteArray(1, MiBandService::COMMAND_ACTIVITY_DATA_START_DATE) + QByteArray(1, MiBandService::COMMAND_ACTIVITY_DATA_TYPE_ACTIVTY) + rawDate);
}

void ActivityFetchOperation::handleData(const QByteArray &data)
{
    int len = data.length();

    if (len % 4 != 1) {
        qDebug() << "Unexpected data size";
        return;
    }

    for (int i = 1; i < len; i+=4) {
        ActivitySample sample(data[i] & 0xff, data[i + 1] & 0xff, data[i + 2] & 0xff, data[i + 3] & 0xff);
        m_samples << (sample);
    }
}

bool ActivityFetchOperation::finished(bool success)
{
    bool saved = true;
    if (success) {
        //store the successful samples
        saved = saveSamples();
        if (m_sampleTime.isDaylightTime()) {
            qDebug() << "Adding DST compensation to last sample time";
            m_sampleTime = m_sampleTime.addSecs(3600);
        }
        saveLastActivitySync(m_sampleTime.toMSecsSinceEpoch());
        qDebug() << "finished fetch operation, last record was " << m_sampleTime;
    }
    return saved;
}

bool ActivityFetchOperation::saveSamples()
{
    if (m_samples.count() <= 0) {
        return true;
    }

    if (!m_conn && !m_conn->isDatabaseUsed()) {
        qDebug() << "Database not connected";
        return false;
    }

    m_sampleTime = startDate();
    qDebug() << "Start sample time" << m_sampleTime;

    auto config = AmazfishConfig::instance();
    uint id = qHash(config->profileName());
    uint devid = qHash(config->pairedAddress());

    KDbTransaction transaction = m_conn->beginTransaction();
    KDbTransactionGuard tg(transaction);

    KDbFieldList fields;
    auto mibandActivity = m_conn->tableSchema("mi_band_activity");

    fields.addField(mibandActivity->field("timestamp"));
    fields.addField(mibandActivity->field("timestamp_dt"));
    fields.addField(mibandActivity->field("device_id"));
    fields.addField(mibandActivity->field("user_id"));
    fields.addField(mibandActivity->field("raw_intensity"));
    fields.addField(mibandActivity->field("steps"));
    fields.addField(mibandActivity->field("raw_kind"));
    fields.addField(mibandActivity->field("heartrate"));

    QDateTime saveTime;

    for (int i = 0; i < m_samples.count(); ++i) {
        QList<QVariant> values;


        values << m_sampleTime.toMSecsSinceEpoch() / 1000;
        values << m_sampleTime;
        values << devid;
        values << id;
        values << m_samples[i].intensity();
        values << m_samples[i].steps();
        values << m_samples[i].kind();
        values << m_samples[i].heartrate();

        if (!m_conn->insertRecord(&fields, values)) {
            qDebug() << "error inserting record";
            return false;
        }
        m_sampleTime = m_sampleTime.addSecs(60);
    }
    tg.commit();

    return true;
}

