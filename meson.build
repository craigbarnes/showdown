project('showdown', ['vala', 'c'])

resources = import('gnome').compile_resources (
    'resources',
    'res/resources.xml',
    source_dir: 'res'
)

libmarkdown = dependency('libmarkdown', version: '>= 2.2.1', required: false)
if libmarkdown.found() == false
    cc = meson.get_compiler('c')
    libmarkdown = cc.find_library('libmarkdown', required: true)
endif

executable (
    'showdown',
    install: true,
    sources: [
        'showdown.vala',
        'window.vala',
        'view.vala',
        resources
    ],
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.20'),
        dependency('glib-2.0', version: '>= 2.48'),
        dependency('gobject-2.0', version: '>= 2.48'),
        dependency('webkit2gtk-4.0', version: '>= 2.8.4'),
        libmarkdown
    ],
    vala_args: [
        '--target-glib=2.48',
        '--gresources=' + meson.current_source_dir() + '/res/resources.xml',
        '--vapidir=' + meson.current_source_dir(),
        '--pkg=libmarkdown'
    ],
    c_args: [
        '-Wno-incompatible-pointer-types',
        '-Wno-discarded-qualifiers',
        '-Wno-unused-but-set-variable'
    ]
)

datadir = get_option('datadir')
desktopdir = join_paths(datadir, 'applications')
icondir = join_paths(datadir, 'icons', 'hicolor')
appicondir = join_paths(icondir, 'scalable', 'apps')

install_data('res/showdown.svg', install_dir: appicondir)
install_data('share/org.gnome.Showdown.desktop', install_dir: desktopdir)

meson.add_install_script (
    'mk/postinstall.sh',
    join_paths(get_option('prefix'), desktopdir),
    join_paths(get_option('prefix'), icondir)
)
