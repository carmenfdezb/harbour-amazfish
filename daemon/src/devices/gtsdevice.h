#ifndef GTSDEVICE_H
#define GTSDEVICE_H

#include <QObject>
#include "bipdevice.h"

class GtsDevice : public BipDevice
{
public:
    explicit GtsDevice(const QString &pairedName, QObject *parent = nullptr);

    virtual QString deviceType() override;
    virtual void sendAlert(const QString &sender, const QString &subject, const QString &message) override;
    virtual void sendEventReminder(int id, const QDateTime &dt, const QString &event) override;
    virtual int supportedFeatures() override;
    void prepareFirmwareDownload(const AbstractFirmwareInfo *info) override;

    virtual AbstractFirmwareInfo *firmwareInfo(const QByteArray &bytes) override;

    virtual void sendWeather(CurrentWeather *weather) override;
    virtual void enableFeature(AbstractDevice::Feature feature) override;
    virtual void setMusicStatus(bool playing, const QString &title, const QString &artist, const QString &album) override;

private:
    void initialise();
    void parseServices();

    virtual void onPropertiesChanged(QString interface, QVariantMap map, QStringList list) override;
    Q_SLOT void serviceEvent(char event);

private:
    QString pairedName;
};

#endif // GTSDEVICE_H
