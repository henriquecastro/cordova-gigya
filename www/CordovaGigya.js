var argscheck = require('cordova/argscheck'),
	utils = require('cordova/utils'),
	exec = require('cordova/exec');

module.exports = {

	initialize: function(api_key, api_domain) {
		console.log('initialize');
		exec(null,
			null,
			"CordovaGigya",
			"initialize", [api_key, (api_domain || "us1.gigya.com")]);
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

	showAddConnectionUI: function(providers, params, success, failure) {
		console.log('showAddConnectionUI');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"showAddConnectionUI", [providers, params]);
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

	getCurrentUser: function(params, success, failure) {
		console.log('getCurrentUser');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"getCurrentUser", [params]);
	},

	requestFacebookPublishPermissions: function(params, success, failure) {
		console.log('requestFacebookPublishPermissions');
		exec(success || function() {},
			failure || function() {},
			"CordovaGigya",
			"requestFacebookPublishPermissions", [params]);
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