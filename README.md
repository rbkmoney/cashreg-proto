# kkt-proto


[![Build Status](http://ci.rbkmoney.com/buildStatus/icon?job=rbkmoney_private/kkt-proto/master)](http://ci.rbkmoney.com/job/rbkmoney_private/job/kkt-proto/job/master/)


Требования к оформлению Thrift IDL файлов
Namespace:

В каждом файле нужно обязательно указывать namespace для JAVA:

  namespace java com.rbkmoney.damsel.<name>
Где <name> - имя, уникальное для Thrift IDL файлa в Damsel.

Java development
Собрать пакет и инсталировать новый jar в локальный мавен репозиторий:

make wc_compile
make wc_java_install LOCAL_BUILD=true SETTINGS_XML=path_to_rbk_maven_settings
Чтобы ипользовать несколько версий дамзели в проекте используте classifier:v${commit.number}

<dependency>
    <groupId>com.rbkmoney</groupId>
    <artifactId>damsel</artifactId>
    <version>1.136-07b0898</version>
    <classifier>v136</classifier>
</dependency>
