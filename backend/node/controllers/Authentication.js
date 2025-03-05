'use strict';

var utils = require('../utils/writer.js');
var Authentication = require('../service/AuthenticationService');

module.exports.authForgot_passwordPOST = function authForgot_passwordPOST (req, res, next) {
  var emailInfo = req.swagger.params['emailInfo'].value;
  Authentication.authForgot_passwordPOST(emailInfo)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};

module.exports.authLoginPOST = function authLoginPOST (req, res, next) {
  var credentials = req.swagger.params['credentials'].value;
  Authentication.authLoginPOST(credentials)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};

module.exports.authRegisterPOST = function authRegisterPOST (req, res, next) {
  var user = req.swagger.params['user'].value;
  Authentication.authRegisterPOST(user)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};

module.exports.authReset_passwordPOST = function authReset_passwordPOST (req, res, next) {
  var resetInfo = req.swagger.params['resetInfo'].value;
  Authentication.authReset_passwordPOST(resetInfo)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};

module.exports.authVerify_emailGET = function authVerify_emailGET (req, res, next) {
  var token = req.swagger.params['token'].value;
  Authentication.authVerify_emailGET(token)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};
