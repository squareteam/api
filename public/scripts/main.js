require.config({
    paths: {
        jquery: '../bower_components/jquery/jquery',
        requirejs: '../bower_components/requirejs/require',
        underscore: '../bower_components/underscore/underscore',
        backbone: '../bower_components/backbone/backbone',
        offline: '../bower_components/offline/offline.min',
        when: '../bower_components/when/when',
        'when-sequence': '../bower_components/when/sequence',
        loglevel: '../bower_components/loglevel/dist/loglevel.min',
        sizzle: '../bower_components/sizzle/dist/sizzle',
        'jquery.cookie': '../bower_components/jquery.cookie/jquery.cookie',
        cryptojslib: '../bower_components/cryptojslib/**/*',
        'cryptojs.pbkdf2': '../bower_components/cryptojslib/rollups/pbkdf2',
        'cryptojs.hmac.sha256': '../bower_components/cryptojslib/rollups/hmac-sha256',
        hbs: '../bower_components/require-handlebars-plugin/hbs',
        'hbs/handlebars': '../bower_components/require-handlebars-plugin/hbs/handlebars',
        'hbs/underscore': '../bower_components/require-handlebars-plugin/hbs/underscore',
        'hbs/i18nprecompile': '../bower_components/require-handlebars-plugin/hbs/i18nprecompile',
        'hbs/json2': '../bower_components/require-handlebars-plugin/hbs/json2',
        'backbone-forms': '../bower_components/backbone-forms/distribution.amd/backbone-forms',
        'backbone-forms-bootstrap': '../bower_components/backbone-forms/distribution.amd/templates/bootstrap3'
    },
    shim: {
        jquery: {
            exports: 'jQuery'
        },
        underscore: {
            exports: '_'
        },
        backbone: {
            deps: [
                'jquery',
                'underscore'
            ],
            exports: 'Backbone'
        },
        app: {
            deps: [
                'underscore',
                'backbone',
                'jquery',
                'backbone-forms',
                'backbone-forms-bootstrap',
                'apps/public/login',
                'apps/public/register'
            ]
        }
    }
});

require(['app'], function () {
});
