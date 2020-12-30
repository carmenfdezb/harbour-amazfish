#ifndef ABSTRACTOPERATION_H
#define ABSTRACTOPERATION_H

#include "qble/qbleservice.h"

class AbstractOperation
{
public:
    AbstractOperation(QBLEService *service);
    virtual ~AbstractOperation(){}
    
    virtual void start() = 0;
    virtual bool handleMetaData(const QByteArray &meta) = 0;
    virtual void handleData(const QByteArray &data) = 0;
    virtual bool finished(bool success);
    bool busy();
protected:
    QBLEService *m_service;
    bool m_busy = false;
};

#endif // ABSTRACTOPERATION_H
