var argscheck = require('cordova/argscheck'),
	utils = require('cordova/utils'),
	exec = require('cordova/exec');

module.exports = {

	initialize: function(api_key) {
		console.log('initialize');
		exec(null,
			null,
			"CordovaGigya",
			"initialize", [api_key]);
	},

	showLoginUI: function(providers, params, success, failure) {
		console.log('showLoginUI');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"showLoginUI", [providers, params]);
	},

	login: function(provider, params, success, failure) {
		console.log('login');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"login", [provider, params]);
	},

	loginUserWithPassword: function(params, success, failure) {
		console.log('loginUserWithPassword');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"loginUserWithPassword", [params]);
	},

	addConnectionToProvider: function(provider, params, success, failure) {
		console.log('addConnectionToProvider');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"addConnectionToProvider", [provider, params]);
	},

	getSession: function(success, failure) {
		console.log('getSession');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"getSession", []);
	},


	sendRequest: function(method, params, success, failure) {
		console.log('sendRequest');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"sendRequest", [method, params]);
	},


	logout: function(success, failure) {
		console.log('logout');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"logout", []);
	}

};