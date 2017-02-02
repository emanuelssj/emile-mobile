QT += qml quick quickcontrols2 svg

CONFIG += c++11

HEADERS += cpp/pushnotificationtokenlistener.h

SOURCES += main.cpp cpp/pushnotificationtokenlistener.cpp

RESOURCES += qml.qrc plugins.qrc

android: {
    QT += androidextras
    HEADERS += android/cpp/androidgallery.h android/JavaToCppBind.h
    SOURCES += android/cpp/androidgallery.cpp

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    OTHER_FILES += \
        android/AndroidManifest.xml \
        android/google-services.json \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/src/gsort/pos/engsisubiq/EmileMobile/TokenToApplication.java \
        android/src/gsort/pos/engsisubiq/EmileMobile/FirebaseListenerService.java \
        android/src/gsort/pos/engsisubiq/EmileMobile/FirebaseInstanceIDListenerService.java
}

ios: {
}

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
