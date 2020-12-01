#ifndef PINETIMEJFDEVICE_H
#define PINETIMEJFDEVICE_H

#include <QObject>
#include "abstractdevice.h"

class PinetimeJFDevice : public AbstractDevice
{
public:
    PinetimeJFDevice(const QString &pairedName, QObject *parent = 0);

    virtual QString pair() override;
    virtual int supportedFeatures() override;
    virtual QString deviceType() override;
    virtual bool operationRunning() override;

    virtual void sendAlert(const QString &sender, const QString &subject, const QString &message) override;
    virtual void incomingCall(const QString &caller) override;

    virtual void refreshInformation() override;
    virtual QString information(Info i) override;

    Q_SLOT void authenticated(bool ready);

    virtual AbstractFirmwareInfo *firmwareInfo(const QByteArray &bytes) override;
    virtual void setMusicStatus(bool playing, const QString &title, const QString &artist, const QString &album) override;

protected:
    virtual void onPropertiesChanged(QString interface, QVariantMap map, QStringList list);

private:
    void parseServices();
    void initialise();
    Q_SLOT void serviceEvent(uint8_t event);

};

#endif // PINETIMEJFDEVICE_H
