#ifndef TYPECONVERSION_H
#define TYPECONVERSION_H
#include <QByteArray>
#include <QDateTime>

namespace TypeConversion {

QByteArray fromInt8(int val);
QByteArray fromInt16(int val);
QByteArray fromInt24(int val);
QByteArray fromInt32(int val);
QByteArray fromUInt32(uint val);
QDateTime rawBytesToDateTime(const QByteArray &value, bool honorDeviceTimeOffset);
QByteArray dateTimeToBytes(const QDateTime &dt, int format, bool adjustForTZ = true);
int toUint16(char val1, char val2);
int toUint32(char val1, char val2, char val3, char val4);
long toUnsigned(int unsignedInt);
int toUnsigned(short value);
int toUnsigned(char value);
int toInt16(char val1, char val2);
int toUint16(char value);
}

#endif // TYPECONVERSION_H
