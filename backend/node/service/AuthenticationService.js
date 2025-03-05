'use strict';


/**
 * Forgot Password
 * Initiates password reset process by sending a reset email.
 *
 * emailInfo EmailInfo Email address of the user requesting password reset
 * no response value expected for this operation
 **/
exports.authForgot_passwordPOST = function(emailInfo) {
  return new Promise(function(resolve, reject) {
    resolve();
  });
}


/**
 * User Login
 * Authenticates a user and returns a JWT token. Login can be done using either email or username.
 *
 * credentials Login User login credentials (provide either email or username along with password)
 * returns inline_response_200
 **/
exports.authLoginPOST = function(credentials) {
  return new Promise(function(resolve, reject) {
    var examples = {};
    examples['application/json'] = {"empty": false};
    if (Object.keys(examples).length > 0) {
      resolve(examples[Object.keys(examples)[0]]);
    } else {
      resolve();
    }
  });
}


/**
 * User Registration
 * Registers a new user account.
 *
 * user Register User registration details
 * no response value expected for this operation
 **/
exports.authRegisterPOST = function(user) {
  return new Promise(function(resolve, reject) {
    resolve();
  });
}


/**
 * Reset Password
 * Resets a user's password using a valid reset token. The reset link sent to the user's email directs them to a page where they enter a new password along with a confirmation. 
 *
 * resetInfo ResetInfo Reset token, new password, and password confirmation
 * no response value expected for this operation
 **/
exports.authReset_passwordPOST = function(resetInfo) {
  return new Promise(function(resolve, reject) {
    resolve();
  });
}


/**
 * Verify Email
 * Verifies user's email address using a token provided via query parameter.
 *
 * token String Email verification token
 * no response value expected for this operation
 **/
exports.authVerify_emailGET = function(token) {
  return new Promise(function(resolve, reject) {
    resolve();
  });
}

