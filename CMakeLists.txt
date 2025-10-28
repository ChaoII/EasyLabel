cmake_minimum_required(VERSION 3.16)

project(EasyLabel VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(HuskarUI_DIR "D:/HuskarUI")

find_package(Qt6 REQUIRED COMPONENTS Quick)


qt_add_executable(appEasyLabel
    main.cpp
)

qt_add_resources(appEasyLabel "images"
    PREFIX "/"
    FILES
    images/logo.svg
)

set_source_files_properties(qml/QmlGlobalHelper.qml
        PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appEasyLabel
    URI EasyLabel
    VERSION 1.0
    QML_FILES
    qml/Main.qml
    qml/Projetc.qml
    qml/ProjectPopup.qml
    qml/component/PopupStandardWindow.qml
    qml/component/DirSelectInput.qml
    qml/QmlGlobalHelper.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appEasyLabel PROPERTIES
    #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appEasyLabel
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appEasyLabel PRIVATE
    "${HuskarUI_DIR}/HuskarUI/include")

target_link_directories(appEasyLabel PRIVATE
    ${HuskarUI_DIR}/HuskarUI/lib
)

target_link_libraries(appEasyLabel
    PRIVATE Qt6::Quick HuskarUIBasic
)

include(GNUInstallDirs)
install(TARGETS appEasyLabel
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
