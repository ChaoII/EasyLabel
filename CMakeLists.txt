cmake_minimum_required(VERSION 3.16)

project(EasyLabel VERSION 0.1 LANGUAGES CXX)


set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(HuskarUI_DIR "D:/HuskarUI")
set(CMAKE_TOOLCHAIN_FILE "E:/vcpkg/scripts/buildsystems/vcpkg.cmake")

find_package(Qt6 REQUIRED COMPONENTS Quick Core)
find_package(SqliteOrm CONFIG REQUIRED)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/src")
qt_add_executable(appEasyLabel
    src/main.cpp
    src/qmlutilscpp.h
    src/qmlutilscpp.cpp
    src/db/schema/schema.h
    src/db/dbHelper.h
    src/db/dbHelper.cpp
    src/projectdto.h
    src/projectdto.cpp
)

qt_add_resources(appEasyLabel "images"
    PREFIX "/"
    FILES
    images/logo.svg
    images/image.jpg
)

set_source_files_properties(
    qml/global/QmlGlobalHelper.qml
    qml/global/GlobalEnum.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appEasyLabel
    URI EasyLabel
    VERSION 1.0
    QML_FILES
    qml/Main.qml
    qml/component/PopupStandardWindow.qml
    qml/component/DirSelectInput.qml
    qml/global/QmlGlobalHelper.qml
    qml/global/GlobalEnum.qml
    qml/project/ProjetcList.qml
    qml/project/ProjectPopup.qml
    qml/project/DetectionDetailComponent.qml
    qml/project/RotatedBoxDetailComponent.qml
    qml/project/OtherDetailComponent.qml
    qml/canvas/MainCanvas.qml
     qml/canvas/CentralAnnotationView.qml
     qml/canvas/AnnotationDetailPanel.qml
     qml/canvas/DetectionLabelLayer.qml
     qml/canvas/CanvasEnums.qml
     qml/component/Crosshair.qml
     qml/component/LineWidthSlider.qml
     qml/component/Cursor.qml
     QML_FILES qml/component/Collapse.qml
     QML_FILES qml/component/ColorSlider.qml
     QML_FILES qml/component/OpacitySlider.qml
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
    PRIVATE Qt6::Quick HuskarUIBasic Qt6::Core sqlite_orm::sqlite_orm
)

include(GNUInstallDirs)
install(TARGETS appEasyLabel
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
