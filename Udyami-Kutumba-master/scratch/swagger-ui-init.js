
window.onload = function() {
  // Build a system
  let url = window.location.search.match(/url=([^&]+)/);
  if (url && url.length > 1) {
    url = decodeURIComponent(url[1]);
  } else {
    url = window.location.origin;
  }
  let options = {
  "swaggerDoc": {
    "openapi": "3.0.0",
    "paths": {
      "/auth/createUser": {
        "post": {
          "operationId": "AuthController_createUser",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/loginUser": {
        "post": {
          "operationId": "AuthController_login",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/LoginDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/getAllUsers": {
        "get": {
          "operationId": "AuthController_getAllUsers",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/getAllChannelPartners": {
        "get": {
          "operationId": "AuthController_getAllChannelPartners",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "description": "Page number",
              "schema": {
                "default": 1,
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "description": "Number of records per page",
              "schema": {
                "default": 10,
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "wardId",
              "required": true,
              "in": "query",
              "description": "Ward UUID to fetch Channel Partners assigned to this ward",
              "schema": {
                "example": "825a3f8c-f9fa-40d6-a291-61401fe8a7a2",
                "type": "string"
              }
            },
            {
              "name": "businessName",
              "required": false,
              "in": "query",
              "description": "Filter Channel Partners by selected business/service name",
              "schema": {
                "example": "Legal Opinion",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/getUserById/{id}": {
        "get": {
          "operationId": "AuthController_getUserById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/deleteUser/{id}": {
        "delete": {
          "operationId": "AuthController_removeUser",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/update-position-permission": {
        "patch": {
          "operationId": "AuthController_updatePositionPermission",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdatePositionPermissionDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/ucn-members/{wardId}": {
        "get": {
          "operationId": "AuthController_getUCNMembers",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/getCpLoginCred/{id}": {
        "get": {
          "operationId": "AuthController_findOneUser",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/auth/getAllPatrons/{talukaId}": {
        "get": {
          "operationId": "AuthController_getUsersByTalukaId",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Auth"
          ]
        }
      },
      "/udyami-members/createUdyamiMembers": {
        "post": {
          "operationId": "UdyamiMembersController_createUdyamiMembers",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMemberDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiMembers"
          ]
        }
      },
      "/udyami-members/getAllUdyamiMembers": {
        "get": {
          "operationId": "UdyamiMembersController_getAllMembers",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "description": "Page number",
              "schema": {
                "default": 1,
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "description": "Number of records per page",
              "schema": {
                "default": 10,
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "ward",
              "required": false,
              "in": "query",
              "description": "Filter members by ward",
              "schema": {
                "example": "Ward 5",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiMembers"
          ]
        }
      },
      "/udyami-members/{memberId}/profile": {
        "patch": {
          "operationId": "UdyamiMembersController_updateMemberProfile",
          "parameters": [
            {
              "name": "memberId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateMemberDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiMembers"
          ]
        }
      },
      "/udyami-members/my-members/{userId}": {
        "get": {
          "operationId": "UdyamiMembersController_getMyMembers",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "page",
              "required": false,
              "in": "query",
              "description": "Page number",
              "schema": {
                "default": 1,
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "description": "Number of records per page",
              "schema": {
                "default": 10,
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "ward",
              "required": false,
              "in": "query",
              "description": "Filter members by ward",
              "schema": {
                "example": "Ward 5",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiMembers"
          ]
        }
      },
      "/roles/createRole": {
        "post": {
          "operationId": "RolesController_createRole",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateRoleDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/assignRole": {
        "post": {
          "operationId": "RolesController_assignRole",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AssignRoleDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/getAllRoles": {
        "get": {
          "operationId": "RolesController_getAllRoles",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/getAllRoleUsers": {
        "get": {
          "operationId": "RolesController_getAllRoleUsers",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/getRoleUserById/{id}": {
        "get": {
          "operationId": "RolesController_getRoleUserById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/updateUserRoleById/{id}": {
        "patch": {
          "operationId": "RolesController_updateRoleUser",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateUserRoleDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/deleteRole/{id}": {
        "delete": {
          "operationId": "RolesController_deleteRole",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Roles"
          ]
        }
      },
      "/roles/remove-from-position": {
        "post": {
          "operationId": "RolesController_removeUserFromPosition",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/RemoveUserFromPositionDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "summary": "Remove a user from their position and transfer it to a new user. Position and Assignment remain unchanged.",
          "tags": [
            "Roles"
          ]
        }
      },
      "/cp-surveys/createSurvey": {
        "post": {
          "operationId": "CpSurveysController_createSurvey",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateCpSurveyDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpSurveys"
          ]
        }
      },
      "/cp-surveys/getAllSurveys": {
        "get": {
          "operationId": "CpSurveysController_getAllSurveys",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpSurveys"
          ]
        }
      },
      "/cp-surveys/getMySurveys/{cpId}": {
        "get": {
          "operationId": "CpSurveysController_getMySurveys",
          "parameters": [
            {
              "name": "cpId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpSurveys"
          ]
        }
      },
      "/cp-surveys/updateSurvey/{id}": {
        "patch": {
          "operationId": "CpSurveysController_updateSurvey",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateCpSurveyDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpSurveys"
          ]
        }
      },
      "/cp-surveys/deleteSurvey/{id}": {
        "delete": {
          "operationId": "CpSurveysController_deleteSurvey",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpSurveys"
          ]
        }
      },
      "/lead/createLead": {
        "post": {
          "operationId": "LeadController_createLead",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateLeadDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Lead"
          ]
        }
      },
      "/lead/getAllLeads": {
        "get": {
          "operationId": "LeadController_getAllLeads",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Lead"
          ]
        }
      },
      "/lead/getLeadsById/{id}": {
        "get": {
          "operationId": "LeadController_getLeadById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Lead"
          ]
        }
      },
      "/lead/updateLead/{id}": {
        "patch": {
          "operationId": "LeadController_updateLead",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateLeadDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Lead"
          ]
        }
      },
      "/lead/deleteLead/{id}": {
        "delete": {
          "operationId": "LeadController_deleteLead",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Lead"
          ]
        }
      },
      "/lead-activities/createLeadActivity": {
        "post": {
          "operationId": "LeadActivitiesController_createLeadActivity",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateLeadActivityDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "LeadActivities"
          ]
        }
      },
      "/lead-activities/getAllLeadActivities": {
        "get": {
          "operationId": "LeadActivitiesController_getAllLeadActivities",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "LeadActivities"
          ]
        }
      },
      "/lead-activities/getLeadActivity/{leadId}": {
        "get": {
          "operationId": "LeadActivitiesController_getLeadActivitiesByLeadId",
          "parameters": [
            {
              "name": "leadId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "LeadActivities"
          ]
        }
      },
      "/lead-activities/updateLeadActivities/{id}": {
        "patch": {
          "operationId": "LeadActivitiesController_updateLeadActivity",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateLeadActivityDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "LeadActivities"
          ]
        }
      },
      "/lead-activities/deleteLeadActivities/{id}": {
        "delete": {
          "operationId": "LeadActivitiesController_deleteLeadActivity",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "LeadActivities"
          ]
        }
      },
      "/udyami-payments/createUdyamiPayment": {
        "post": {
          "operationId": "UdyamiPaymentsController_createPayment",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreatePaymentUdyamiDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiPayments"
          ]
        }
      },
      "/udyami-payments/getAllUdyamiPayments": {
        "get": {
          "operationId": "UdyamiPaymentsController_getAllPayments",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiPayments"
          ]
        }
      },
      "/udyami-payments/getPaymentDetailsById/{id}": {
        "get": {
          "operationId": "UdyamiPaymentsController_getPaymentById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiPayments"
          ]
        }
      },
      "/udyami-payments/getPaymentDetailsByMemberId/{memberId}": {
        "get": {
          "operationId": "UdyamiPaymentsController_getPaymentsByMemberId",
          "parameters": [
            {
              "name": "memberId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiPayments"
          ]
        }
      },
      "/udyami-payments/deletePaymentDetailsById/{id}": {
        "delete": {
          "operationId": "UdyamiPaymentsController_deletePaymentById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UdyamiPayments"
          ]
        }
      },
      "/campaigns/createCampaign": {
        "post": {
          "operationId": "CampaignsController_createCampaign",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateCampaignDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Campaigns"
          ]
        }
      },
      "/campaigns/getAllCampaigns": {
        "get": {
          "operationId": "CampaignsController_getAllCampaigns",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Campaigns"
          ]
        }
      },
      "/campaigns/getCompaginById/{id}": {
        "get": {
          "operationId": "CampaignsController_getCampaignById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Campaigns"
          ]
        }
      },
      "/member-points/createMemberPoints": {
        "post": {
          "operationId": "MemberPointsController_createMemberPoint",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMemberPointDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/member-points/getAllMemberPoints": {
        "get": {
          "operationId": "MemberPointsController_getAllMemberPoints",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/member-points/getMemberPointsById/{id}": {
        "get": {
          "operationId": "MemberPointsController_getMemberPointById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/member-points/getMemberPointsByMemberId/{memberId}": {
        "get": {
          "operationId": "MemberPointsController_getMemberPointsByMemberId",
          "parameters": [
            {
              "name": "memberId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/member-points/updateMemberPoints/{id}": {
        "patch": {
          "operationId": "MemberPointsController_updateMemberPoint",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateMemberPointDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/member-points/deleteMemberPoints/{id}": {
        "delete": {
          "operationId": "MemberPointsController_deleteMemberPoint",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MemberPoints"
          ]
        }
      },
      "/referrals/createReferral": {
        "post": {
          "operationId": "ReferralsController_createReferral",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateReferralDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Referrals"
          ]
        }
      },
      "/referrals/getAllReferrals": {
        "get": {
          "operationId": "ReferralsController_getAllReferrals",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Referrals"
          ]
        }
      },
      "/referrals/getReferralsById/{id}": {
        "get": {
          "operationId": "ReferralsController_getReferralById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Referrals"
          ]
        }
      },
      "/referrals/updateReferrals/{id}": {
        "patch": {
          "operationId": "ReferralsController_updateReferral",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateReferralDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            },
            {
              "JWT": []
            }
          ],
          "tags": [
            "Referrals"
          ]
        }
      },
      "/referrals/deleteReferrals/{id}": {
        "delete": {
          "operationId": "ReferralsController_deleteReferral",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Referrals"
          ]
        }
      },
      "/gps-pings/createGpsPings": {
        "post": {
          "operationId": "GpsPingsController_createGpsPing",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateGpsPingDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "GpsPings"
          ]
        }
      },
      "/gps-pings/getAllgpsPings": {
        "get": {
          "operationId": "GpsPingsController_getAllGpsPings",
          "parameters": [
            {
              "name": "page",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "GpsPings"
          ]
        }
      },
      "/gps-pings/getGpsPingsById/{id}": {
        "get": {
          "operationId": "GpsPingsController_getGpsPingById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "GpsPings"
          ]
        }
      },
      "/gps-pings/updateGpsPings/{id}": {
        "patch": {
          "operationId": "GpsPingsController_updateGpsPing",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateGpsPingDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "GpsPings"
          ]
        }
      },
      "/gps-pings/deleteGpsPings/{id}": {
        "delete": {
          "operationId": "GpsPingsController_deleteGpsPing",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "GpsPings"
          ]
        }
      },
      "/ward/create": {
        "post": {
          "operationId": "WardController_createWard",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "wardName": {
                      "type": "string"
                    },
                    "wardNumber": {
                      "type": "string"
                    },
                    "districtId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "talukaId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "geoJsonFile": {
                      "type": "string",
                      "format": "binary"
                    }
                  },
                  "required": [
                    "wardName",
                    "wardNumber",
                    "districtId",
                    "talukaId",
                    "geoJsonFile"
                  ]
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/getAllWards": {
        "get": {
          "operationId": "WardController_getAllWards",
          "parameters": [
            {
              "name": "wardName",
              "required": false,
              "in": "query",
              "description": "Filter by ward name",
              "schema": {
                "example": "Kudlu",
                "type": "string"
              }
            },
            {
              "name": "district",
              "required": false,
              "in": "query",
              "description": "Filter by district",
              "schema": {
                "example": "Bengaluru Urban",
                "type": "string"
              }
            },
            {
              "name": "taluka",
              "required": false,
              "in": "query",
              "description": "Filter by taluka",
              "schema": {
                "example": "Anekal",
                "type": "string"
              }
            },
            {
              "name": "state",
              "required": false,
              "in": "query",
              "description": "Filter by state",
              "schema": {
                "example": "Karnataka",
                "type": "string"
              }
            },
            {
              "name": "wardNumber",
              "required": false,
              "in": "query",
              "description": "Filter by ward number",
              "schema": {
                "example": "12",
                "type": "string"
              }
            },
            {
              "name": "page",
              "required": false,
              "in": "query",
              "schema": {
                "default": 1,
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "schema": {
                "default": 10,
                "example": 10,
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/getWardBy/{talukaId}": {
        "get": {
          "operationId": "WardController_getWardsByTalukaId",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/getWardByName/{wardName}": {
        "get": {
          "operationId": "WardController_getWardByName",
          "parameters": [
            {
              "name": "wardName",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/map/{name}": {
        "get": {
          "operationId": "WardController_getMap",
          "parameters": [
            {
              "name": "name",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "type",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/{wardId}": {
        "patch": {
          "operationId": "WardController_updateWard",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateWardDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/usersByRole": {
        "get": {
          "operationId": "WardController_getUsersByRole",
          "parameters": [
            {
              "name": "role",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/users-by-ward": {
        "get": {
          "operationId": "WardController_getUsersByWard",
          "parameters": [
            {
              "name": "ward",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/ward/getAllUcnMembersUnderWard/{wardId}": {
        "get": {
          "operationId": "WardController_getWardMembershipUsers",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Ward"
          ]
        }
      },
      "/userprofile/createUserProfile": {
        "post": {
          "operationId": "UserprofileController_createUserProfile",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "$ref": "#/components/schemas/CreateUserProfileDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/userprofile/search-users": {
        "post": {
          "operationId": "UserprofileController_searchUsers",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SearchUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/userprofile/getUserProfileById/{userId}": {
        "get": {
          "operationId": "UserprofileController_getProfileByUserId",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/userprofile/updateUserProfile/{userId}": {
        "patch": {
          "operationId": "UserprofileController_updateUserProfile",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateUserProfileDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/userprofile/deleteUserProfile/{userId}": {
        "delete": {
          "operationId": "UserprofileController_deleteUserProfile",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/userprofile/business-verticals": {
        "post": {
          "operationId": "UserprofileController_createBusinessVertical",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateBusinessVerticalDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        },
        "get": {
          "operationId": "UserprofileController_getAllBusinessVerticals",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Userprofile"
          ]
        }
      },
      "/ward-chart/createWardChartData": {
        "post": {
          "operationId": "WardChartController_createWardChart",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "data": {
                      "type": "string",
                      "example": "{\"wardHeadId\":\"3e14b4b8-c4d4-42ab-8e2d-0ab8e5d7a111\",\"ward\":\"Ward 1\",\"layoutConfig\":{},\"members\":[{\"userType\":\"Chairman\",\"name\":\"John Doe\",\"mobileNumber\":\"9876543210\",\"email\":\"john@test.com\",\"companyName\":\"ABC Pvt Ltd\"},{\"userType\":\"Vice Chairman\",\"name\":\"Jane Doe\",\"mobileNumber\":\"9876543211\",\"email\":\"jane@test.com\",\"companyName\":\"XYZ Pvt Ltd\"}]}"
                    },
                    "wardChartProfileImage": {
                      "type": "string",
                      "format": "binary"
                    },
                    "profileImages": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/ward-chart/getWardChartData/{userId}/{wardId}": {
        "get": {
          "operationId": "WardChartController_getWardChart",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/ward-chart/getLocationByWardHeadId/{wardHeadId}": {
        "get": {
          "operationId": "WardChartController_getLocationByWardHeadId",
          "parameters": [
            {
              "name": "wardHeadId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/ward-chart/deleteWardChartMember/{memberId}": {
        "delete": {
          "operationId": "WardChartController_deleteWardChartMember",
          "parameters": [
            {
              "name": "memberId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/ward-chart/hierarchy/{userId}": {
        "get": {
          "operationId": "WardChartController_getHierarchyByUserId",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/ward-chart/getWardChartByWardName/{wardName}": {
        "get": {
          "operationId": "WardChartController_getWardMembers",
          "parameters": [
            {
              "name": "wardName",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "WardChart"
          ]
        }
      },
      "/assignment/assign-talukas": {
        "post": {
          "operationId": "AssignmentController_assignTalukas",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AssignTalukasToDistrictDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Assignment"
          ]
        }
      },
      "/assignment/assign-wards": {
        "post": {
          "operationId": "AssignmentController_assignWards",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AssignWardsToTalukaDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Assignment"
          ]
        }
      },
      "/district/createDistricts": {
        "post": {
          "operationId": "DistrictController_createDistrict",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateDistrictDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "District"
          ]
        }
      },
      "/district/adminAssignDistrictHead": {
        "post": {
          "operationId": "DistrictController_assignDistrictHead",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AdminAssignDistrictHeadDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "District"
          ]
        }
      },
      "/district/getAllDistricts": {
        "get": {
          "operationId": "DistrictController_getAllDistricts",
          "parameters": [
            {
              "name": "districtId",
              "required": false,
              "in": "query",
              "description": "Pass districtId to get talukas. Leave empty to get all districts.",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "District"
          ]
        }
      },
      "/district/getDistrictById/{id}": {
        "get": {
          "operationId": "DistrictController_getDistrictById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "District"
          ]
        }
      },
      "/district/users-by-district": {
        "get": {
          "operationId": "DistrictController_getUsersByDistrict",
          "parameters": [
            {
              "name": "district",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "District"
          ]
        }
      },
      "/talukas/createTaluka": {
        "post": {
          "operationId": "TalukasController_createTaluka",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateTalukaDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/getAllTalukas": {
        "get": {
          "operationId": "TalukasController_getAllTalukas",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/district/{districtId}": {
        "get": {
          "operationId": "TalukasController_getTalukasByDistrict",
          "parameters": [
            {
              "name": "districtId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/assignWardsToWardHead": {
        "post": {
          "operationId": "TalukasController_assignWard",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AssignWardDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/assigned-ward/{wardHeadId}": {
        "get": {
          "operationId": "TalukasController_getAssignedWard",
          "parameters": [
            {
              "name": "wardHeadId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/users-by-taluka": {
        "get": {
          "operationId": "TalukasController_getUsersByTaluka",
          "parameters": [
            {
              "name": "taluka",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/getAllWardChaimansBy/{talukaId}": {
        "get": {
          "operationId": "TalukasController_getWardsByTalukaId",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/getAssemblyLeadership/{talukaId}": {
        "get": {
          "operationId": "TalukasController_getAssemblyLeadershipByTaluka",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/talukas/getAllUcnMembersUnderTaluka/{talukaId}": {
        "get": {
          "operationId": "TalukasController_getTalukaMembershipUsers",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Talukas"
          ]
        }
      },
      "/udyamimngt/designations": {
        "get": {
          "operationId": "UdyamimngtController_getAllDesignations",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Udyamimngt"
          ]
        }
      },
      "/udyamimngt/assign": {
        "post": {
          "operationId": "UdyamimngtController_assignDesignation",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AssignDesignationDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Udyamimngt"
          ]
        }
      },
      "/udyamimngt/getMngtMembers/{wardId}": {
        "get": {
          "operationId": "UdyamimngtController_getDesignationAssignmentsByWardId",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Designation assignments fetched successfully.",
              "content": {
                "application/json": {
                  "schema": {
                    "example": {
                      "success": true,
                      "message": "Designation assignments fetched successfully.",
                      "data": [
                        {
                          "assignmentId": "7f2c7f3d-xxxx",
                          "designation": {
                            "designationId": "uuid",
                            "designationName": "AI Lead Generation",
                            "description": "Manage AI leads",
                            "isActive": true
                          },
                          "ward": {
                            "wardId": "uuid",
                            "wardName": "Ward 1"
                          },
                          "assignedBy": {
                            "userId": "uuid",
                            "name": "Admin",
                            "email": "admin@test.com"
                          },
                          "createdAt": "2026-08-06T10:00:00.000Z",
                          "holder": {
                            "designationHolderId": "uuid",
                            "user": {
                              "userId": "uuid",
                              "name": "Suraj",
                              "email": "suraj@test.com"
                            },
                            "fromDate": "2026-08-06T10:00:00.000Z",
                            "toDate": null,
                            "isCurrent": true
                          }
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "summary": "Get designation assignments and holders by ward id",
          "tags": [
            "Udyamimngt"
          ]
        }
      },
      "/udyamimngt/assigned-members/circle-leader/{circleLeaderId}": {
        "get": {
          "operationId": "UdyamimngtController_getAssignedMembersByCircleLeader",
          "parameters": [
            {
              "name": "circleLeaderId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Udyamimngt"
          ]
        }
      },
      "/udyamimngt/replace-holder": {
        "patch": {
          "operationId": "UdyamimngtController_replaceDesignationHolder",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ReplaceDesignationHolderDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Udyamimngt"
          ]
        }
      },
      "/wallet/addWalletData": {
        "post": {
          "operationId": "WalletController_createWallet",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AddCoinsDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Wallet"
          ]
        }
      },
      "/wallet/getWalletData/{userId}": {
        "get": {
          "operationId": "WalletController_getWallet",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Wallet"
          ]
        }
      },
      "/send-email/sendSingleMail": {
        "post": {
          "operationId": "SendEmailController_renderEmail",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/RenderEmailDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SendEmail"
          ]
        }
      },
      "/send-email/sendBulkMail/{campaignId}": {
        "post": {
          "operationId": "SendEmailController_sendBulkCampaign",
          "parameters": [
            {
              "name": "campaignId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SendEmail"
          ]
        }
      },
      "/bulk-campagin/createBulkCampagians": {
        "post": {
          "operationId": "BulkCampaginController_createBulkCampaign",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateBulkCampaignDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/getAllCampaigns": {
        "get": {
          "operationId": "BulkCampaginController_getAllCampaigns",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "description": "Page number",
              "schema": {
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "description": "Records per page",
              "schema": {
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "userId",
              "required": false,
              "in": "query",
              "description": "User Id",
              "schema": {
                "example": "f4f5d3d2-2d74-4c86-9d59-2f5cb5d9eaf1",
                "type": "string"
              }
            },
            {
              "name": "adminStatus",
              "required": false,
              "in": "query",
              "description": "Campaign Admin Status",
              "schema": {
                "type": "string",
                "enum": [
                  "DRAFT",
                  "PENDING",
                  "APPROVED",
                  "REJECTED",
                  "PROCESSING",
                  "SCHEDULED",
                  "COMPLETED",
                  "FAILED"
                ]
              }
            },
            {
              "name": "channel",
              "required": false,
              "in": "query",
              "schema": {
                "example": "EMAIL",
                "type": "string",
                "enum": [
                  "EMAIL",
                  "SMS",
                  "WHATSAPP",
                  "IVR"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/getCampaignRecipients": {
        "get": {
          "operationId": "BulkCampaginController_getAllCampaignRecipients",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/upload": {
        "post": {
          "operationId": "BulkCampaginController_uploadCsv",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "required": [
                    "userId",
                    "file",
                    "channel",
                    "scheduledAt"
                  ],
                  "properties": {
                    "userId": {
                      "type": "string",
                      "example": "7c6aab80-7a34-4c8d-9c2d-53b8e8b4d3f7"
                    },
                    "file": {
                      "type": "string",
                      "format": "binary"
                    },
                    "voiceFile": {
                      "type": "string",
                      "format": "binary",
                      "nullable": true
                    },
                    "channel": {
                      "type": "string",
                      "enum": [
                        "EMAIL",
                        "SMS",
                        "WHATSAPP",
                        "IVR"
                      ]
                    },
                    "templateId": {
                      "type": "string",
                      "nullable": true
                    },
                    "subject": {
                      "type": "string",
                      "example": "Special Offer",
                      "nullable": true
                    },
                    "message": {
                      "type": "string",
                      "example": "Hello, this is our campaign message.",
                      "nullable": true
                    },
                    "scheduledAt": {
                      "type": "string",
                      "format": "date-time",
                      "example": "2026-07-25T10:00:00.000Z"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/getAllUploadedCsvData": {
        "get": {
          "operationId": "BulkCampaginController_getAllUploads",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "schema": {
                "default": 1,
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "schema": {
                "default": 10,
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "status",
              "required": false,
              "in": "query",
              "schema": {
                "example": "PENDING",
                "type": "string",
                "enum": [
                  "PENDING",
                  "APPROVED",
                  "REJECTED",
                  "COMPLETED"
                ]
              }
            },
            {
              "name": "userId",
              "required": false,
              "in": "query",
              "schema": {
                "example": "7c6aab80-7a34-4c8d-9c2d-53b8e8b4d3f7",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/getUploadedCsvDat/{userId}": {
        "get": {
          "operationId": "BulkCampaginController_getUploadsByUser",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/reviewMemberCampagin": {
        "patch": {
          "operationId": "BulkCampaginController_reviewUploads",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ReviewUploadDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/bulk-campagin/getCampaginReport/{userId}": {
        "get": {
          "operationId": "BulkCampaginController_getCampaignReport",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BulkCampagin"
          ]
        }
      },
      "/mobile-msg/send": {
        "post": {
          "operationId": "MobileMsgController_sendSms",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SendSmsDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MobileMsg"
          ]
        }
      },
      "/mobile-msg/sendBulkSMS": {
        "post": {
          "operationId": "MobileMsgController_sendBulkSms",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SendBulkCampaignDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MobileMsg"
          ]
        }
      },
      "/meetings/createAsemblyBasedMeetings": {
        "post": {
          "operationId": "MeetingsController_create",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMeetingDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAllAssemblyMeetings/{talukaId}": {
        "get": {
          "operationId": "MeetingsController_getMeetingsByTalukaId",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAllMeetings/created-by/{userId}": {
        "get": {
          "operationId": "MeetingsController_getMeetingsByCreatedUserId",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAllWardPositionsUsers/{talukaId}": {
        "get": {
          "operationId": "MeetingsController_getWardPositionUsersByTalukaId",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/createWardBasedMeetings": {
        "post": {
          "operationId": "MeetingsController_createwardBasedMeetings",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMeetingDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAllWardMeetings/{wardId}": {
        "get": {
          "operationId": "MeetingsController_getMeetingsByWardId",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getWardMembersWithDesignations/{wardId}": {
        "get": {
          "operationId": "MeetingsController_getWardMembersWithDesignations",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAllMeetings": {
        "get": {
          "operationId": "MeetingsController_getAllMeetings",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getMeetingsById/{id}": {
        "get": {
          "operationId": "MeetingsController_getMeetingsById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/updateMemberMeetings/{meetingId}": {
        "patch": {
          "operationId": "MeetingsController_updateMeeting",
          "parameters": [
            {
              "name": "meetingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateMeetingDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/respondMemberMeetings": {
        "post": {
          "operationId": "MeetingsController_respondToInvitation",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateMeetingRsvpDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/meetings/getAcceptedMeetings": {
        "get": {
          "operationId": "MeetingsController_getAcceptedMeetings",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Meetings"
          ]
        }
      },
      "/directory/searchMembers": {
        "post": {
          "operationId": "DirectoryController_searchMembers",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SearchMemberDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Directory"
          ]
        }
      },
      "/bni-lead/createLead": {
        "post": {
          "operationId": "BniLeadController_createLead",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateBniLeadDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/{leadId}/status": {
        "patch": {
          "operationId": "BniLeadController_updateLeadStatus",
          "parameters": [
            {
              "name": "leadId",
              "required": true,
              "in": "path",
              "description": "Lead UUID",
              "schema": {
                "example": "d8c5db7d-2d0c-4f8f-9d2c-65c4c0c4c3b5",
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateLeadStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/getAllLeads": {
        "get": {
          "operationId": "BniLeadController_getAllLeads",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/getLeadsByid": {
        "post": {
          "operationId": "BniLeadController_getLeadsByCreatedUser",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/GetLeadsByUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/completed-by-user": {
        "post": {
          "operationId": "BniLeadController_getCompletedLeadsByCreatedUser",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/GetLeadsByUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/converted-by-user": {
        "post": {
          "operationId": "BniLeadController_getPendingLeadsByCreatedUser",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/GetLeadsByUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/free-member-leads": {
        "get": {
          "operationId": "BniLeadController_getAllFreeMembersLeads",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/bni-lead/paid-member-leads": {
        "get": {
          "operationId": "BniLeadController_getAllPaidMembersLeads",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniLead"
          ]
        }
      },
      "/facetoface/createFaceToFace": {
        "post": {
          "operationId": "FacetofaceController_createFaceToFace",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateFaceToFaceDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/updateFaceToFace/{meetingId}/status": {
        "patch": {
          "operationId": "FacetofaceController_updateFaceToFaceStatus",
          "parameters": [
            {
              "name": "meetingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateFaceToFaceStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/getAllFaceToFaceMeetings": {
        "get": {
          "operationId": "FacetofaceController_getAllFaceToFaceMeetings",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/getFaceToFaceMeetingsByCreatedUserId": {
        "post": {
          "operationId": "FacetofaceController_getFaceToFaceByCreatedUser",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/GetFaceToFaceByUserDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/DeleteFaceToFaceMeetingsById": {
        "delete": {
          "operationId": "FacetofaceController_deleteFaceToFace",
          "parameters": [
            {
              "name": "meetingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DeleteFaceToFaceDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/invited-member/{invitedMemberUserId}": {
        "get": {
          "operationId": "FacetofaceController_getMeetingsByInvitedMember",
          "parameters": [
            {
              "name": "invitedMemberUserId",
              "required": true,
              "in": "path",
              "description": "Invited Member User ID",
              "schema": {
                "example": "1a0d56f3-68bd-4517-bf0f-1c0ea93157a4",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/createContactSphere": {
        "post": {
          "operationId": "FacetofaceController_createContactSphere",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateContactSphereDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/contactSphere": {
        "get": {
          "operationId": "FacetofaceController_getContactSphereByUsers",
          "parameters": [
            {
              "name": "createdUserId",
              "required": false,
              "in": "query",
              "description": "User ID. If only this is provided, returns all Contact Sphere records for this user.",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "invitedMemberUserId",
              "required": false,
              "in": "query",
              "description": "Invited member User ID. Optional. If both IDs are provided, both directions are returned.",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/facetoface/updateContactSphere/{contactSphereId}": {
        "patch": {
          "operationId": "FacetofaceController_updateContactSphere",
          "parameters": [
            {
              "name": "contactSphereId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateContactSphereDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Facetoface"
          ]
        }
      },
      "/uc-training/createUCTrainings": {
        "post": {
          "operationId": "UcTrainingController_createUctranings",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateUcTrainingDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UcTraining"
          ]
        }
      },
      "/uc-training/getAllTrainings": {
        "get": {
          "operationId": "UcTrainingController_getAllUCTRainings",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UcTraining"
          ]
        }
      },
      "/uc-training/getUCTrainingsByID/{id}": {
        "get": {
          "operationId": "UcTrainingController_getUCtrainingById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UcTraining"
          ]
        }
      },
      "/uc-training/updateUCTrainingsById/{id}": {
        "patch": {
          "operationId": "UcTrainingController_updateUCTrainings",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateUcTrainingDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UcTraining"
          ]
        }
      },
      "/uc-training/deleteUCTRainings/{id}": {
        "delete": {
          "operationId": "UcTrainingController_removeUCTrainings",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "UcTraining"
          ]
        }
      },
      "/gratitude/CreateGratitudeSlip": {
        "post": {
          "operationId": "GratitudeController_CreateGratitudeSlip",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "thankYouMemberUserId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "leadId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "businessValue": {
                      "type": "number"
                    },
                    "type": {
                      "type": "string"
                    },
                    "createdUserId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "feedback": {
                      "type": "string"
                    },
                    "utrNo": {
                      "type": "string"
                    },
                    "proofImages": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "summary": "Create Gratitude Slip",
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/gratitude/gratitude-slips/ward": {
        "get": {
          "operationId": "GratitudeController_getGratitudeSlipsByWard",
          "parameters": [
            {
              "name": "wardName",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/gratitude/getGratitudeSlipsByID/{id}": {
        "get": {
          "operationId": "GratitudeController_getGratitudeSlipsById",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/gratitude/getGratitudeSlipByCreatedUser/{userId}": {
        "get": {
          "operationId": "GratitudeController_getByCreatedUser",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/gratitude/updateGratitudeSlip/{id}": {
        "patch": {
          "operationId": "GratitudeController_updateGratitudeSlip",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateGratitudeSlipDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/gratitude/deleteGratitudeSlip/{id}": {
        "delete": {
          "operationId": "GratitudeController_deleteGratitudeSlip",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Gratitude"
          ]
        }
      },
      "/bni-guest/createGuest": {
        "post": {
          "operationId": "BniGuestController_createGuest",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateGuestDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/bni-guest/getAllGuests": {
        "get": {
          "operationId": "BniGuestController_getAllGuests",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/bni-guest/getGuestById/{guestId}": {
        "get": {
          "operationId": "BniGuestController_getGuestById",
          "parameters": [
            {
              "name": "guestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/bni-guest/getGuest/{createdUserId}": {
        "get": {
          "operationId": "BniGuestController_getGuestsByCreatedUser",
          "parameters": [
            {
              "name": "createdUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/bni-guest/updateGuestData/{guestId}": {
        "patch": {
          "operationId": "BniGuestController_updateGuest",
          "parameters": [
            {
              "name": "guestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateGuestDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/bni-guest/deleteGuestBy/{guestId}": {
        "delete": {
          "operationId": "BniGuestController_deleteGuest",
          "parameters": [
            {
              "name": "guestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "BniGuest"
          ]
        }
      },
      "/hall-booking/createHallBooking": {
        "post": {
          "operationId": "HallBookingController_createHallBooking",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateHallBookingDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "HallBooking"
          ]
        }
      },
      "/hall-booking/getBookingHallData/{createdUserId}": {
        "get": {
          "operationId": "HallBookingController_getHallBookingsByCreatedUser",
          "parameters": [
            {
              "name": "createdUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "HallBooking"
          ]
        }
      },
      "/hall-booking/getAllHallBookings": {
        "get": {
          "operationId": "HallBookingController_getAllHallBookings",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "HallBooking"
          ]
        }
      },
      "/hall-booking/updateBookingData/{hallBookingId}": {
        "patch": {
          "operationId": "HallBookingController_updateHallBooking",
          "parameters": [
            {
              "name": "hallBookingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateHallBookingDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "HallBooking"
          ]
        }
      },
      "/hall-booking/deleteHallBooking/ {hallBookingId}": {
        "delete": {
          "operationId": "HallBookingController_deleteHallBooking",
          "parameters": [
            {
              "name": "hallBookingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "HallBooking"
          ]
        }
      },
      "/sector/getAllSectors": {
        "get": {
          "operationId": "SectorController_getAllSectors",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector": {
        "post": {
          "operationId": "SectorController_createSectorJoinRequest",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateSectorJoinRequestDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        },
        "get": {
          "operationId": "SectorController_getAllSectorJoinRequests",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/{sectorJoinRequestId}": {
        "get": {
          "operationId": "SectorController_getSectorJoinRequestById",
          "parameters": [
            {
              "name": "sectorJoinRequestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        },
        "delete": {
          "operationId": "SectorController_deleteSectorJoinRequest",
          "parameters": [
            {
              "name": "sectorJoinRequestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/created-user/{createdUserId}": {
        "get": {
          "operationId": "SectorController_getSectorJoinRequestsByCreatedUser",
          "parameters": [
            {
              "name": "createdUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/member/{userId}": {
        "get": {
          "operationId": "SectorController_getSectorJoinRequestsByUser",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/{sectorJoinRequestId}/endorse": {
        "patch": {
          "operationId": "SectorController_endorseSectorJoinRequest",
          "parameters": [
            {
              "name": "sectorJoinRequestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/{sectorJoinRequestId}/approve": {
        "patch": {
          "operationId": "SectorController_approveSectorJoinRequest",
          "parameters": [
            {
              "name": "sectorJoinRequestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/{sectorJoinRequestId}/reject": {
        "patch": {
          "operationId": "SectorController_rejectSectorJoinRequest",
          "parameters": [
            {
              "name": "sectorJoinRequestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/RejectSectorJoinRequestDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/getAllSubSectors/{sectorId}": {
        "get": {
          "operationId": "SectorController_getSubSectorsBySectorId",
          "parameters": [
            {
              "name": "sectorId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/sector/createBusinessTags": {
        "post": {
          "operationId": "SectorController_createBusinessTag",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateBusinessTagDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Sector"
          ]
        }
      },
      "/attendance/CreateAttendanceSession": {
        "post": {
          "operationId": "AttendanceController_createAttendanceSession",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateAttendanceSessionDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/session/{id}/qr": {
        "get": {
          "operationId": "AttendanceController_generateQr",
          "parameters": [
            {
              "name": "id",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/session/{meetingId}": {
        "get": {
          "operationId": "AttendanceController_getActiveSession",
          "parameters": [
            {
              "name": "meetingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/scanQR": {
        "post": {
          "operationId": "AttendanceController_scanAttendance",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ScanQrDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/addManualAttendance": {
        "patch": {
          "operationId": "AttendanceController_manualAttendance",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ManualAttendanceDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/meeting/{meetingId}": {
        "get": {
          "operationId": "AttendanceController_getMeetingAttendance",
          "parameters": [
            {
              "name": "meetingId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/attendance/close-session": {
        "post": {
          "operationId": "AttendanceController_closeAttendanceSession",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CloseAttendanceSessionDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Attendance"
          ]
        }
      },
      "/applications/applyForMembership": {
        "post": {
          "operationId": "ApplicationsController_createMembershipApplication",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMembershipApplicationDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/applications/getAllApplications": {
        "get": {
          "operationId": "ApplicationsController_getAllMembershipApplications",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/applications/getMembershipApplicationById/{applicationId}": {
        "get": {
          "operationId": "ApplicationsController_getMembershipApplicationById",
          "parameters": [
            {
              "name": "applicationId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/applications/getApplicationByGuestId/{guestId}": {
        "get": {
          "operationId": "ApplicationsController_getApplicationByGuestId",
          "parameters": [
            {
              "name": "guestId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/applications/reviewMEmbershipApplication": {
        "patch": {
          "operationId": "ApplicationsController_reviewMembershipApplication",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ReviewMembershipApplicationDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/applications/statistics": {
        "get": {
          "operationId": "ApplicationsController_getMembershipApplicationStatistics",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Applications"
          ]
        }
      },
      "/socring-weights/getAllScoringWeights": {
        "get": {
          "operationId": "SocringWeightsController_getScoringSettings",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/socring-weights/updateScoringWeights": {
        "put": {
          "operationId": "SocringWeightsController_updateScoringSettings",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateScoringSettingsDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/socring-weights/scorecard/{userId}": {
        "get": {
          "operationId": "SocringWeightsController_getUserScorecard",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/socring-weights/leaderboard/ward": {
        "get": {
          "operationId": "SocringWeightsController_getWardLeaderboard",
          "parameters": [
            {
              "name": "wardName",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/socring-weights/getTalukaLeaderboard/{talukaId}": {
        "get": {
          "operationId": "SocringWeightsController_getTalukaLeaderboard",
          "parameters": [
            {
              "name": "talukaId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/socring-weights/getAssemblyScoreCard/{assemblyId}": {
        "get": {
          "operationId": "SocringWeightsController_getAssemblyWardScorecard",
          "parameters": [
            {
              "name": "assemblyId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "SocringWeights"
          ]
        }
      },
      "/membership-purchase/createMembershipPlans": {
        "post": {
          "operationId": "MembershipPurchaseController_createMembershipPlan",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMembershipPlanDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/membershipAllPlans": {
        "get": {
          "operationId": "MembershipPurchaseController_getAllMembershipPlans",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/updateMembershipPlan/{planId}": {
        "patch": {
          "operationId": "MembershipPurchaseController_updateMembershipPlan",
          "parameters": [
            {
              "name": "planId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateMembershipPlanDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/update-membership": {
        "patch": {
          "operationId": "MembershipPurchaseController_updateUserMembership",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateUserMembershipDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/create-order": {
        "post": {
          "operationId": "MembershipPurchaseController_createOrder",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateMembershipOrderDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/verify-payment": {
        "post": {
          "operationId": "MembershipPurchaseController_verifyPayment",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/VerifyMembershipPaymentDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/receipt/{paymentId}": {
        "get": {
          "operationId": "MembershipPurchaseController_downloadReceipt",
          "parameters": [
            {
              "name": "paymentId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/membership-purchase/membership-history": {
        "get": {
          "operationId": "MembershipPurchaseController_getMembershipHistory",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "query",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "MembershipPurchase"
          ]
        }
      },
      "/news/createNews": {
        "post": {
          "operationId": "NewsController_createNews",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateNewsDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "News"
          ]
        }
      },
      "/news/getAllNews": {
        "get": {
          "operationId": "NewsController_getAllNews",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "schema": {
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "schema": {
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "category",
              "required": false,
              "in": "query",
              "schema": {
                "example": "Business",
                "type": "string"
              }
            },
            {
              "name": "search",
              "required": false,
              "in": "query",
              "schema": {
                "example": "government",
                "type": "string"
              }
            },
            {
              "name": "isFeatured",
              "required": false,
              "in": "query",
              "schema": {
                "example": true,
                "type": "boolean"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "News"
          ]
        }
      },
      "/news/getFeaturedNews": {
        "get": {
          "operationId": "NewsController_getFeaturedNews",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "News"
          ]
        }
      },
      "/news/updateNews/{newsId}": {
        "patch": {
          "operationId": "NewsController_updateNews",
          "parameters": [
            {
              "name": "newsId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateNewsDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "News"
          ]
        }
      },
      "/news/deleteNews/{newsId}": {
        "delete": {
          "operationId": "NewsController_deleteNews",
          "parameters": [
            {
              "name": "newsId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "News"
          ]
        }
      },
      "/jobs/createJob": {
        "post": {
          "operationId": "JobsController_createJob",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateJobDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/getAllJobs": {
        "get": {
          "operationId": "JobsController_getAllJobs",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "schema": {
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "schema": {
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "search",
              "required": false,
              "in": "query",
              "schema": {
                "example": "developer",
                "type": "string"
              }
            },
            {
              "name": "city",
              "required": false,
              "in": "query",
              "schema": {
                "example": "Pune",
                "type": "string"
              }
            },
            {
              "name": "jobType",
              "required": false,
              "in": "query",
              "schema": {
                "type": "string",
                "enum": [
                  "FULL_TIME",
                  "PART_TIME",
                  "CONTRACT",
                  "INTERNSHIP",
                  "FREELANCE"
                ]
              }
            },
            {
              "name": "status",
              "required": false,
              "in": "query",
              "schema": {
                "type": "string",
                "enum": [
                  "OPEN",
                  "CLOSED"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/updateJob/{jobId}": {
        "patch": {
          "operationId": "JobsController_updateJob",
          "parameters": [
            {
              "name": "jobId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateJobDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "summary": "Update Job",
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/deleteJob/{jobId}": {
        "delete": {
          "operationId": "JobsController_deleteJob",
          "parameters": [
            {
              "name": "jobId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "summary": "Delete Job",
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/applyJob": {
        "post": {
          "operationId": "JobsController_applyJob",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ApplyJobDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/getAllApplications": {
        "get": {
          "operationId": "JobsController_getAllApplications",
          "parameters": [
            {
              "name": "page",
              "required": false,
              "in": "query",
              "schema": {
                "example": 1,
                "type": "number"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "schema": {
                "example": 10,
                "type": "number"
              }
            },
            {
              "name": "search",
              "required": false,
              "in": "query",
              "schema": {
                "example": "suraj",
                "type": "string"
              }
            },
            {
              "name": "jobId",
              "required": false,
              "in": "query",
              "schema": {
                "example": "9b4f6df4-9c43-4f34-8c2d-2e3d7f0d2e87",
                "type": "string"
              }
            },
            {
              "name": "status",
              "required": false,
              "in": "query",
              "schema": {
                "type": "string",
                "enum": [
                  "APPLIED",
                  "UNDER_REVIEW",
                  "SHORTLISTED",
                  "REJECTED",
                  "HIRED"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Jobs"
          ]
        }
      },
      "/jobs/deleteApplication/{applicationId}": {
        "delete": {
          "operationId": "JobsController_deleteApplication",
          "parameters": [
            {
              "name": "applicationId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Jobs"
          ]
        }
      },
      "/cp-on-boarding/business-verticals": {
        "get": {
          "operationId": "CpOnBoardingController_getAllBusinessVerticals",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/sub-business-vertical": {
        "post": {
          "operationId": "CpOnBoardingController_createSubBusinessVertical",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateSubBusinessVerticalDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        },
        "get": {
          "operationId": "CpOnBoardingController_getAllSubBusinessVerticals",
          "parameters": [],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/sub-business-vertical/{verticalId}": {
        "get": {
          "operationId": "CpOnBoardingController_getSubBusinessVerticalsByVerticalId",
          "parameters": [
            {
              "name": "verticalId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/create-form": {
        "post": {
          "operationId": "CpOnBoardingController_createForm",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateChannelPartnerFormDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/form/{wardChairmanUserId}": {
        "get": {
          "operationId": "CpOnBoardingController_getFormByWardChairman",
          "parameters": [
            {
              "name": "wardChairmanUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/submit": {
        "post": {
          "operationId": "CpOnBoardingController_submitForm",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "formId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "userId": {
                      "type": "string",
                      "format": "uuid"
                    },
                    "answers": {
                      "type": "string",
                      "example": "{\"fullName\":\"Suraj Sukale\",\"mobile\":\"9876543210\"}"
                    },
                    "files": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/channel-partners/ward/{ward}": {
        "get": {
          "operationId": "CpOnBoardingController_getAllChannelPartnersByWard",
          "parameters": [
            {
              "name": "ward",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/getAllCPSubmittedDataCreatedBYWardChairman/{userId}": {
        "get": {
          "operationId": "CpOnBoardingController_getFormsWithSubmissions",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/getAllCPData/{userId}": {
        "get": {
          "operationId": "CpOnBoardingController_getSubmittedFormsByUser",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/update-status": {
        "patch": {
          "operationId": "CpOnBoardingController_updateSubmissionStatus",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateSubmissionStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/assigned-forms/{channelPartnerId}": {
        "get": {
          "operationId": "CpOnBoardingController_getAssignedForms",
          "parameters": [
            {
              "name": "channelPartnerId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/getAllSubmittedData/{channelPartnerId}": {
        "get": {
          "operationId": "CpOnBoardingController_getSubmissionsByChannelPartnerId",
          "parameters": [
            {
              "name": "channelPartnerId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/submitServeyData": {
        "post": {
          "operationId": "CpOnBoardingController_createCompleteSurvey",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "cpUserId": {
                      "type": "string",
                      "format": "uuid",
                      "example": "f9a6257c-7cbe-4c1c-a25a-8403ee801110"
                    },
                    "subBusinessId": {
                      "type": "string",
                      "format": "uuid",
                      "example": "a2d3e4f5-6789-4abc-9012-345678901234"
                    },
                    "houseImages": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      },
                      "description": "Upload multiple house images. Maximum 10 images."
                    },
                    "latitude": {
                      "type": "number",
                      "example": 12.9715987
                    },
                    "longitude": {
                      "type": "number",
                      "example": 77.5945627
                    },
                    "surveyNumber": {
                      "type": "string",
                      "example": "BBMP-SR-2026-001245"
                    },
                    "locationAddress": {
                      "type": "string",
                      "example": "No. 25, 3rd Main Road, Vijayanagar, Bengaluru"
                    },
                    "locationType": {
                      "type": "string",
                      "enum": [
                        "EMPTY_PLOT",
                        "RESIDENCE",
                        "SEMI_RESIDENCE",
                        "BUILDING",
                        "COMMERCIAL",
                        "INDUSTRIAL",
                        "AGRICULTURAL",
                        "INSTITUTIONAL",
                        "MIXED_USE",
                        "OTHERS"
                      ],
                      "example": "RESIDENCE"
                    },
                    "numberOfFloors": {
                      "type": "integer",
                      "example": 2
                    },
                    "floors": {
                      "type": "string",
                      "example": "[{\"floorNumber\":0,\"floorType\":\"GROUND\",\"usageType\":\"RESIDENTIAL\",\"residentialOccupancy\":\"OWNER_OCCUPIED\",\"occupancyType\":\"SELF OCCUPIED\"},{\"floorNumber\":1,\"floorType\":\"UPPER\",\"usageType\":\"RESIDENTIAL\",\"residentialOccupancy\":\"RENTED\",\"occupancyType\":\"TENANT OCCUPIED\"},{\"floorNumber\":2,\"floorType\":\"UPPER\",\"usageType\":\"COMMERCIAL\",\"residentialOccupancy\":null,\"occupancyType\":\"OFFICE\"}]"
                    }
                  },
                  "required": [
                    "cpUserId",
                    "houseImages",
                    "latitude",
                    "longitude",
                    "surveyNumber",
                    "locationAddress",
                    "locationType",
                    "numberOfFloors",
                    "floors"
                  ]
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/getCPSubmittedData/{cpUserId}": {
        "get": {
          "operationId": "CpOnBoardingController_getSurveysByCpUserId",
          "parameters": [
            {
              "name": "cpUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/updateSurveyStatusByWardChairman/{surveyId}": {
        "patch": {
          "operationId": "CpOnBoardingController_updateSurveyStatus",
          "parameters": [
            {
              "name": "surveyId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateSurveyStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/cp-on-boarding/getAllMyRewardPoints/{cpUserId}": {
        "get": {
          "operationId": "CpOnBoardingController_getMyRewardPoints",
          "parameters": [
            {
              "name": "cpUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CpOnBoarding"
          ]
        }
      },
      "/create-route/createRoute": {
        "post": {
          "operationId": "CreateRouteController_createRoute",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateRouteDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/getAllRoutesCreatedBy/{wardChairmanId}": {
        "get": {
          "operationId": "CreateRouteController_getRoutesByWardChairman",
          "parameters": [
            {
              "name": "wardChairmanId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/getAssignedRoute/{channelPartnerId}": {
        "get": {
          "operationId": "CreateRouteController_getAssignedRoute",
          "parameters": [
            {
              "name": "channelPartnerId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/updateRoute": {
        "patch": {
          "operationId": "CreateRouteController_updateRoute",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateRouteDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/start-journey/{routeId}": {
        "patch": {
          "operationId": "CreateRouteController_startJourney",
          "parameters": [
            {
              "name": "routeId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "channelPartnerId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/updateLiveLocation": {
        "post": {
          "operationId": "CreateRouteController_updateLocation",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateRouteLocationDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/trackCPRoute/{routeId}": {
        "get": {
          "operationId": "CreateRouteController_trackChannelPartnerRoute",
          "parameters": [
            {
              "name": "routeId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/complete-journey/{routeId}": {
        "patch": {
          "operationId": "CreateRouteController_completeJourney",
          "parameters": [
            {
              "name": "routeId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "channelPartnerId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/create-route/journey-reports/{type}/{userId}": {
        "get": {
          "operationId": "CreateRouteController_getJourneyReports",
          "parameters": [
            {
              "name": "type",
              "required": true,
              "in": "path",
              "schema": {
                "enum": [
                  "channel_partner",
                  "ward_chairman"
                ],
                "type": "string"
              }
            },
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "example": "02c79b5d-696a-4883-976d-80a866e440cf",
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CreateRoute"
          ]
        }
      },
      "/cloud-patra/registerCloudPatraCp/application": {
        "post": {
          "operationId": "CloudPatraController_createChannelPartnerApplication",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateChannelPartnerApplicationDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/getMyApplications/{userId}": {
        "get": {
          "operationId": "CloudPatraController_getChannelPartnerApplicationsByUserId",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/getAllApplicationsByWard/{wardId}": {
        "get": {
          "operationId": "CloudPatraController_getChannelPartnerApplicationsByWardId",
          "parameters": [
            {
              "name": "wardId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/updateStatusOfApplications/{applicationId}/status": {
        "patch": {
          "operationId": "CloudPatraController_updateApplicationStatus",
          "parameters": [
            {
              "name": "applicationId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateChannelPartnerApplicationStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/scheduleInterviewByWardChairman/interviews": {
        "post": {
          "operationId": "CloudPatraController_scheduleInterview",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ScheduleInterviewDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/getAllScheduleInterviewBy/{wardChairmanUserId}": {
        "get": {
          "operationId": "CloudPatraController_getInterviewsByScheduledByUserId",
          "parameters": [
            {
              "name": "wardChairmanUserId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/getAllScheduleInterviewsBy/{applicationId}": {
        "get": {
          "operationId": "CloudPatraController_getInterviewByApplicationId",
          "parameters": [
            {
              "name": "applicationId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/cloud-patra/updateInterviewStatus/{interviewId}": {
        "patch": {
          "operationId": "CloudPatraController_updateInterviewStatus",
          "parameters": [
            {
              "name": "interviewId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdateInterviewStatusDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "CloudPatra"
          ]
        }
      },
      "/feed/createPost": {
        "post": {
          "operationId": "FeedController_createPost",
          "parameters": [],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "userId": {
                      "type": "string",
                      "example": "8b7d6e5f-1234-4567-8901-abcdef123456"
                    },
                    "content": {
                      "type": "string",
                      "example": "Today we completed an important community meeting."
                    },
                    "images": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      }
                    }
                  },
                  "required": [
                    "userId"
                  ]
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/getAllPosts": {
        "get": {
          "operationId": "FeedController_getFeed",
          "parameters": [
            {
              "name": "cursor",
              "required": false,
              "in": "query",
              "description": "Cursor returned from the previous feed API response. Leave empty for the first request.",
              "schema": {
                "example": "MjAyNi0wOC0yMVQxMjozMDowMC4wMDBafDUy...",
                "type": "string"
              }
            },
            {
              "name": "limit",
              "required": false,
              "in": "query",
              "description": "Number of posts to return.",
              "schema": {
                "minimum": 1,
                "maximum": 50,
                "default": 20,
                "example": 20,
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/getPostById/{postId}": {
        "get": {
          "operationId": "FeedController_getPost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/getPostBy/{userId}": {
        "get": {
          "operationId": "FeedController_getPostsByUserId",
          "parameters": [
            {
              "name": "userId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            },
            {
              "name": "limit",
              "required": true,
              "in": "query",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/updatePost/{postId}": {
        "patch": {
          "operationId": "FeedController_updatePost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UpdatePostDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/deletePost/{postId}": {
        "delete": {
          "operationId": "FeedController_deletePost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/{postId}/like": {
        "post": {
          "operationId": "FeedController_likePost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/PostLikeDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        },
        "delete": {
          "operationId": "FeedController_unlikePost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/PostLikeDto"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/addComments/{postId}": {
        "post": {
          "operationId": "FeedController_createComment",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreatePostCommentDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/addReactionBy/{commentId}": {
        "post": {
          "operationId": "FeedController_addCommentReaction",
          "parameters": [
            {
              "name": "commentId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CreateCommentReactionDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      },
      "/feed/sharePost{postId}": {
        "post": {
          "operationId": "FeedController_sharePost",
          "parameters": [
            {
              "name": "postId",
              "required": true,
              "in": "path",
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SharePostDto"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": ""
            }
          },
          "security": [
            {
              "JWT": []
            }
          ],
          "tags": [
            "Feed"
          ]
        }
      }
    },
    "info": {
      "title": "Udyami Circle Backend API",
      "description": "REST APIs for Udyami Application",
      "version": "1.0.0",
      "contact": {}
    },
    "tags": [],
    "servers": [],
    "components": {
      "securitySchemes": {
        "JWT": {
          "scheme": "bearer",
          "bearerFormat": "JWT",
          "type": "http",
          "in": "header",
          "description": "Enter JWT Token"
        }
      },
      "schemas": {
        "CreateUserDto": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "example": "Ramesh Kumar",
              "description": "Full name of the user"
            },
            "email": {
              "type": "string",
              "example": "ramesh.kumar@gmail.com",
              "description": "Email address"
            },
            "password": {
              "type": "string",
              "example": "P@ssw0rd123",
              "description": "User password"
            },
            "mobileNumber": {
              "type": "string",
              "example": "9876543210",
              "description": "10-digit mobile number"
            },
            "businessLocation": {
              "type": "string",
              "example": "Hubballi, Karnataka",
              "description": "Business location"
            },
            "officeLocation": {
              "type": "string",
              "example": "Dharwad, Karnataka",
              "description": "Office location"
            },
            "latitude": {
              "type": "number",
              "example": 15.3647,
              "description": "Latitude"
            },
            "longitude": {
              "type": "number",
              "example": 75.124,
              "description": "Longitude"
            },
            "hasBusiness": {
              "type": "boolean",
              "example": true,
              "description": "Whether the user has a registered business",
              "default": false
            }
          },
          "required": [
            "name",
            "email",
            "password",
            "mobileNumber"
          ]
        },
        "LoginDto": {
          "type": "object",
          "properties": {
            "cpId": {
              "type": "string",
              "example": "UDYCP0002",
              "description": "CP ID for Channel Partner login"
            },
            "mobileNumber": {
              "type": "string",
              "example": "9874563210",
              "description": "10 digit mobile number"
            },
            "email": {
              "type": "string",
              "example": "ramesh.kumar@gmail.com",
              "description": "Registered email address"
            },
            "password": {
              "type": "string",
              "example": "P@ssw0rd123",
              "description": "User password"
            },
            "otp": {
              "type": "string",
              "example": "1234",
              "description": "One Time Password (OTP)"
            }
          }
        },
        "UpdatePositionPermissionDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "7f498f69-3ab0-45ca-b34d-7d23c3e47bec",
              "description": "User ID whose current position permission needs to be updated"
            },
            "permission": {
              "type": "string",
              "example": "READ_WRITE",
              "enum": [
                "READ_ONLY",
                "WRITE_ONLY",
                "READ_WRITE"
              ],
              "description": "Permission access level for the position"
            }
          },
          "required": [
            "userId",
            "permission"
          ]
        },
        "CreateMemberDto": {
          "type": "object",
          "properties": {
            "fullName": {
              "type": "string"
            },
            "lastName": {
              "type": "string"
            },
            "fatherName": {
              "type": "string"
            },
            "motherName": {
              "type": "string"
            },
            "dateOfBirth": {
              "type": "string"
            },
            "gender": {
              "type": "string"
            },
            "maritalStatus": {
              "type": "string"
            },
            "primaryMobile": {
              "type": "string"
            },
            "whatsappNumber": {
              "type": "string"
            },
            "email": {
              "type": "string"
            },
            "preferredChannel": {
              "type": "string"
            },
            "preferredLanguage": {
              "type": "string"
            },
            "bloodGroup": {
              "type": "string"
            },
            "education": {
              "type": "string"
            },
            "familyIncome": {
              "type": "string"
            },
            "currentAddress": {
              "type": "string"
            },
            "permanentAddress": {
              "type": "string"
            },
            "ward": {
              "type": "string"
            },
            "circle": {
              "type": "string"
            },
            "state": {
              "type": "string"
            },
            "pincode": {
              "type": "string"
            },
            "languagesKnown": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "emergencyContactName": {
              "type": "string"
            },
            "emergencyPhone": {
              "type": "string"
            },
            "relationship": {
              "type": "string"
            },
            "govIdType": {
              "type": "string"
            },
            "govIdNumber": {
              "type": "string"
            },
            "ownBusiness": {
              "type": "boolean"
            },
            "businessName": {
              "type": "string"
            },
            "businessType": {
              "type": "string"
            },
            "industrySector": {
              "type": "string"
            },
            "subCategory": {
              "type": "string"
            },
            "businessStage": {
              "type": "string"
            },
            "yearEstablished": {
              "type": "number"
            },
            "annualTurnover": {
              "type": "string"
            },
            "noOfEmployees": {
              "type": "number"
            },
            "gstRegistration": {
              "type": "boolean"
            },
            "gstNumber": {
              "type": "string"
            },
            "msmeRegistration": {
              "type": "boolean"
            },
            "targetCustomer": {
              "type": "string"
            },
            "geographicMarkets": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "salesChannels": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "sellsOnline": {
              "type": "boolean"
            },
            "businessWebsite": {
              "type": "string"
            },
            "bankAccount": {
              "type": "boolean"
            },
            "primaryProductsServices": {
              "type": "string"
            },
            "onlineSalesChannels": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "biggestChallenges": {
              "type": "string"
            },
            "supportNeeded": {
              "type": "string"
            },
            "takenBusinessLoan": {
              "type": "boolean"
            },
            "seekingFunding": {
              "type": "boolean"
            },
            "fieldOfStudy": {
              "type": "string"
            },
            "certifications": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "skillProficiency": {
              "type": "string"
            },
            "yearsOfExperience": {
              "type": "number"
            },
            "salesExpertise": {
              "type": "boolean"
            },
            "digitalMarketing": {
              "type": "boolean"
            },
            "financialSkills": {
              "type": "boolean"
            },
            "itTechSkills": {
              "type": "boolean"
            },
            "publicSpeaking": {
              "type": "boolean"
            },
            "contentCreation": {
              "type": "boolean"
            },
            "culinarySkills": {
              "type": "boolean"
            },
            "artCraftSkills": {
              "type": "boolean"
            },
            "professionalSkills": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "interests": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "wantNewSkills": {
              "type": "boolean"
            },
            "willingToMentor": {
              "type": "boolean"
            },
            "openToCollaborate": {
              "type": "boolean"
            },
            "tags": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "homemaker": {
              "type": "boolean"
            },
            "wantHomeBusiness": {
              "type": "boolean"
            },
            "relevantExperience": {
              "type": "boolean"
            },
            "homeBusinessInterests": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "hasEquipment": {
              "type": "boolean"
            },
            "darkStoreInterest": {
              "type": "boolean"
            },
            "existingCustomers": {
              "type": "boolean"
            },
            "productSupport": {
              "type": "boolean"
            },
            "comfortableOnline": {
              "type": "boolean"
            },
            "hasSmartphone": {
              "type": "boolean"
            },
            "trainingAvailability": {
              "type": "string"
            },
            "monthlyIncomeTarget": {
              "type": "string"
            },
            "wantMentor": {
              "type": "boolean"
            },
            "willingToMentorWomen": {
              "type": "boolean"
            },
            "finalYearStudent": {
              "type": "boolean"
            },
            "courseDegree": {
              "type": "string"
            },
            "institution": {
              "type": "string"
            },
            "graduationYear": {
              "type": "number"
            },
            "interestedInEntrepreneurship": {
              "type": "boolean"
            },
            "hasBusinessIdea": {
              "type": "boolean"
            },
            "interestedSectors": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "startupCompetitions": {
              "type": "boolean"
            },
            "financialSupport": {
              "type": "boolean"
            },
            "businessIdeaDescription": {
              "type": "string"
            },
            "problemToSolve": {
              "type": "string"
            },
            "workWithBusinesses": {
              "type": "boolean"
            },
            "weeklyHours": {
              "type": "number"
            },
            "techSkills": {
              "type": "boolean"
            },
            "roleModel": {
              "type": "string"
            },
            "socialPlatformsUsed": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "primaryPlatform": {
              "type": "string"
            },
            "dailyUsage": {
              "type": "string"
            },
            "followers": {
              "type": "number"
            },
            "postFrequency": {
              "type": "string"
            },
            "whatsappBusiness": {
              "type": "boolean"
            },
            "googleMyBusiness": {
              "type": "boolean"
            },
            "digitalPayments": {
              "type": "boolean"
            },
            "procuresOnline": {
              "type": "boolean"
            },
            "createContent": {
              "type": "boolean"
            },
            "businessSoftware": {
              "type": "string"
            },
            "smartphoneComfort": {
              "type": "string"
            },
            "wantDigitalMarketingTraining": {
              "type": "boolean"
            },
            "howHeardAboutUs": {
              "type": "string"
            },
            "referrerName": {
              "type": "string"
            },
            "referrerUdyamiId": {
              "type": "string"
            },
            "existingAssociation": {
              "type": "boolean"
            },
            "attendsNetworking": {
              "type": "boolean"
            },
            "knownBusinesses": {
              "type": "string"
            },
            "biggestOpportunityInArea": {
              "type": "string"
            },
            "infrastructureChallenges": {
              "type": "string"
            },
            "willingToRefer": {
              "type": "boolean"
            },
            "canHostMeeting": {
              "type": "boolean"
            },
            "awareOfGovSchemes": {
              "type": "boolean"
            },
            "unservedBusinessNeeds": {
              "type": "string"
            },
            "createdByUserId": {
              "type": "string"
            },
            "businessLat": {
              "type": "object"
            },
            "businessLng": {
              "type": "object"
            }
          },
          "required": [
            "fullName",
            "lastName",
            "fatherName",
            "motherName",
            "dateOfBirth",
            "gender",
            "maritalStatus",
            "primaryMobile",
            "whatsappNumber",
            "email",
            "preferredChannel",
            "preferredLanguage",
            "bloodGroup",
            "education",
            "familyIncome",
            "currentAddress",
            "permanentAddress",
            "ward",
            "circle",
            "state",
            "pincode",
            "languagesKnown",
            "emergencyContactName",
            "emergencyPhone",
            "relationship",
            "govIdType",
            "govIdNumber",
            "ownBusiness",
            "businessName",
            "businessType",
            "industrySector",
            "subCategory",
            "businessStage",
            "yearEstablished",
            "annualTurnover",
            "noOfEmployees",
            "gstRegistration",
            "gstNumber",
            "msmeRegistration",
            "targetCustomer",
            "geographicMarkets",
            "salesChannels",
            "sellsOnline",
            "businessWebsite",
            "bankAccount",
            "primaryProductsServices",
            "onlineSalesChannels",
            "biggestChallenges",
            "supportNeeded",
            "takenBusinessLoan",
            "seekingFunding",
            "fieldOfStudy",
            "certifications",
            "skillProficiency",
            "yearsOfExperience",
            "salesExpertise",
            "digitalMarketing",
            "financialSkills",
            "itTechSkills",
            "publicSpeaking",
            "contentCreation",
            "culinarySkills",
            "artCraftSkills",
            "professionalSkills",
            "interests",
            "wantNewSkills",
            "willingToMentor",
            "openToCollaborate",
            "tags",
            "homemaker",
            "wantHomeBusiness",
            "relevantExperience",
            "homeBusinessInterests",
            "hasEquipment",
            "darkStoreInterest",
            "existingCustomers",
            "productSupport",
            "comfortableOnline",
            "hasSmartphone",
            "trainingAvailability",
            "monthlyIncomeTarget",
            "wantMentor",
            "willingToMentorWomen",
            "finalYearStudent",
            "courseDegree",
            "institution",
            "graduationYear",
            "interestedInEntrepreneurship",
            "hasBusinessIdea",
            "interestedSectors",
            "startupCompetitions",
            "financialSupport",
            "businessIdeaDescription",
            "problemToSolve",
            "workWithBusinesses",
            "weeklyHours",
            "techSkills",
            "roleModel",
            "socialPlatformsUsed",
            "primaryPlatform",
            "dailyUsage",
            "followers",
            "postFrequency",
            "whatsappBusiness",
            "googleMyBusiness",
            "digitalPayments",
            "procuresOnline",
            "createContent",
            "businessSoftware",
            "smartphoneComfort",
            "wantDigitalMarketingTraining",
            "howHeardAboutUs",
            "referrerName",
            "referrerUdyamiId",
            "existingAssociation",
            "attendsNetworking",
            "knownBusinesses",
            "biggestOpportunityInArea",
            "infrastructureChallenges",
            "willingToRefer",
            "canHostMeeting",
            "awareOfGovSchemes",
            "unservedBusinessNeeds",
            "createdByUserId",
            "businessLat",
            "businessLng"
          ]
        },
        "UpdateMemberDto": {
          "type": "object",
          "properties": {
            "fullName": {
              "type": "string"
            },
            "lastName": {
              "type": "string"
            },
            "fatherName": {
              "type": "string"
            },
            "motherName": {
              "type": "string"
            },
            "dateOfBirth": {
              "type": "string"
            },
            "gender": {
              "type": "string"
            },
            "maritalStatus": {
              "type": "string"
            },
            "primaryMobile": {
              "type": "string"
            },
            "whatsappNumber": {
              "type": "string"
            },
            "email": {
              "type": "string"
            },
            "preferredChannel": {
              "type": "string"
            },
            "preferredLanguage": {
              "type": "string"
            },
            "bloodGroup": {
              "type": "string"
            },
            "education": {
              "type": "string"
            },
            "familyIncome": {
              "type": "string"
            },
            "currentAddress": {
              "type": "string"
            },
            "permanentAddress": {
              "type": "string"
            },
            "ward": {
              "type": "string"
            },
            "circle": {
              "type": "string"
            },
            "state": {
              "type": "string"
            },
            "pincode": {
              "type": "string"
            },
            "languagesKnown": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "emergencyContactName": {
              "type": "string"
            },
            "emergencyPhone": {
              "type": "string"
            },
            "relationship": {
              "type": "string"
            },
            "govIdType": {
              "type": "string"
            },
            "govIdNumber": {
              "type": "string"
            },
            "ownBusiness": {
              "type": "boolean"
            },
            "businessName": {
              "type": "string"
            },
            "businessType": {
              "type": "string"
            },
            "industrySector": {
              "type": "string"
            },
            "subCategory": {
              "type": "string"
            },
            "businessStage": {
              "type": "string"
            },
            "yearEstablished": {
              "type": "number"
            },
            "annualTurnover": {
              "type": "string"
            },
            "noOfEmployees": {
              "type": "number"
            },
            "gstRegistration": {
              "type": "boolean"
            },
            "gstNumber": {
              "type": "string"
            },
            "msmeRegistration": {
              "type": "boolean"
            },
            "targetCustomer": {
              "type": "string"
            },
            "geographicMarkets": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "salesChannels": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "sellsOnline": {
              "type": "boolean"
            },
            "businessWebsite": {
              "type": "string"
            },
            "bankAccount": {
              "type": "boolean"
            },
            "primaryProductsServices": {
              "type": "string"
            },
            "onlineSalesChannels": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "biggestChallenges": {
              "type": "string"
            },
            "supportNeeded": {
              "type": "string"
            },
            "takenBusinessLoan": {
              "type": "boolean"
            },
            "seekingFunding": {
              "type": "boolean"
            },
            "fieldOfStudy": {
              "type": "string"
            },
            "certifications": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "skillProficiency": {
              "type": "string"
            },
            "yearsOfExperience": {
              "type": "number"
            },
            "salesExpertise": {
              "type": "boolean"
            },
            "digitalMarketing": {
              "type": "boolean"
            },
            "financialSkills": {
              "type": "boolean"
            },
            "itTechSkills": {
              "type": "boolean"
            },
            "publicSpeaking": {
              "type": "boolean"
            },
            "contentCreation": {
              "type": "boolean"
            },
            "culinarySkills": {
              "type": "boolean"
            },
            "artCraftSkills": {
              "type": "boolean"
            },
            "professionalSkills": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "interests": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "wantNewSkills": {
              "type": "boolean"
            },
            "willingToMentor": {
              "type": "boolean"
            },
            "openToCollaborate": {
              "type": "boolean"
            },
            "tags": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "homemaker": {
              "type": "boolean"
            },
            "wantHomeBusiness": {
              "type": "boolean"
            },
            "relevantExperience": {
              "type": "boolean"
            },
            "homeBusinessInterests": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "hasEquipment": {
              "type": "boolean"
            },
            "darkStoreInterest": {
              "type": "boolean"
            },
            "existingCustomers": {
              "type": "boolean"
            },
            "productSupport": {
              "type": "boolean"
            },
            "comfortableOnline": {
              "type": "boolean"
            },
            "hasSmartphone": {
              "type": "boolean"
            },
            "trainingAvailability": {
              "type": "string"
            },
            "monthlyIncomeTarget": {
              "type": "string"
            },
            "wantMentor": {
              "type": "boolean"
            },
            "willingToMentorWomen": {
              "type": "boolean"
            },
            "finalYearStudent": {
              "type": "boolean"
            },
            "courseDegree": {
              "type": "string"
            },
            "institution": {
              "type": "string"
            },
            "graduationYear": {
              "type": "number"
            },
            "interestedInEntrepreneurship": {
              "type": "boolean"
            },
            "hasBusinessIdea": {
              "type": "boolean"
            },
            "interestedSectors": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "startupCompetitions": {
              "type": "boolean"
            },
            "financialSupport": {
              "type": "boolean"
            },
            "businessIdeaDescription": {
              "type": "string"
            },
            "problemToSolve": {
              "type": "string"
            },
            "workWithBusinesses": {
              "type": "boolean"
            },
            "weeklyHours": {
              "type": "number"
            },
            "techSkills": {
              "type": "boolean"
            },
            "roleModel": {
              "type": "string"
            },
            "socialPlatformsUsed": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "primaryPlatform": {
              "type": "string"
            },
            "dailyUsage": {
              "type": "string"
            },
            "followers": {
              "type": "number"
            },
            "postFrequency": {
              "type": "string"
            },
            "whatsappBusiness": {
              "type": "boolean"
            },
            "googleMyBusiness": {
              "type": "boolean"
            },
            "digitalPayments": {
              "type": "boolean"
            },
            "procuresOnline": {
              "type": "boolean"
            },
            "createContent": {
              "type": "boolean"
            },
            "businessSoftware": {
              "type": "string"
            },
            "smartphoneComfort": {
              "type": "string"
            },
            "wantDigitalMarketingTraining": {
              "type": "boolean"
            },
            "howHeardAboutUs": {
              "type": "string"
            },
            "referrerName": {
              "type": "string"
            },
            "referrerUdyamiId": {
              "type": "string"
            },
            "existingAssociation": {
              "type": "boolean"
            },
            "attendsNetworking": {
              "type": "boolean"
            },
            "knownBusinesses": {
              "type": "string"
            },
            "biggestOpportunityInArea": {
              "type": "string"
            },
            "infrastructureChallenges": {
              "type": "string"
            },
            "willingToRefer": {
              "type": "boolean"
            },
            "canHostMeeting": {
              "type": "boolean"
            },
            "awareOfGovSchemes": {
              "type": "boolean"
            },
            "unservedBusinessNeeds": {
              "type": "string"
            },
            "createdByUserId": {
              "type": "string"
            },
            "businessLat": {
              "type": "object"
            },
            "businessLng": {
              "type": "object"
            }
          }
        },
        "CreateRoleDto": {
          "type": "object",
          "properties": {
            "roleName": {
              "type": "string",
              "example": "super_admin",
              "description": "Unique role name stored in the database."
            },
            "role": {
              "type": "string",
              "example": "SuperAdmin",
              "description": "Role identifier used in the application."
            },
            "description": {
              "type": "string",
              "example": "all access for this role",
              "description": "Description of the role."
            }
          },
          "required": [
            "roleName",
            "role"
          ]
        },
        "AssignRoleDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "UUID of the user"
            },
            "roleId": {
              "type": "number",
              "example": 2,
              "description": "Role ID to assign"
            },
            "presidentUserId": {
              "type": "string",
              "description": "Assembly President user ID. Required when assigning Assembly Vice President, General Secretary or Treasurer.",
              "example": "f4da9730-8345-44e9-94f2-7b173448eb73"
            }
          },
          "required": [
            "userId",
            "roleId"
          ]
        },
        "UpdateUserRoleDto": {
          "type": "object",
          "properties": {
            "roleId": {
              "type": "number"
            }
          },
          "required": [
            "roleId"
          ]
        },
        "RemoveUserFromPositionDto": {
          "type": "object",
          "properties": {
            "oldUserId": {
              "type": "string",
              "example": "3e14b4b8-c4d4-42ab-8e2d-0ab8e5d7a111",
              "description": "User currently holding the position, being removed."
            },
            "newUserId": {
              "type": "string",
              "example": "8e9f7a92-83d4-4245-9e6b-9b85dee62a71",
              "description": "User to be assigned the position instead."
            },
            "assignedBy": {
              "type": "string",
              "example": "95d4ac6b-c21a-4ca3-bd20-f94285064584",
              "description": "User performing the transfer (e.g. admin), if applicable."
            },
            "roleId": {
              "type": "number",
              "example": 3,
              "description": "Role to assign to the new user if they do not already have a role. Must match the role required by the position being transferred."
            }
          },
          "required": [
            "oldUserId",
            "newUserId"
          ]
        },
        "CreateCpSurveyDto": {
          "type": "object",
          "properties": {
            "localId": {
              "type": "string",
              "example": "LOCAL-20260717-0001",
              "description": "Unique local survey ID generated by the mobile app."
            },
            "cpId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "Channel Partner User ID."
            },
            "submissionData": {
              "type": "object",
              "example": {
                "ownerName": "Rahul Sharma",
                "businessName": "Sharma Electricals",
                "mobileNumber": "9876543210",
                "category": "Electrical",
                "address": "Main Road, Ward 5, Hubli",
                "hasGST": true,
                "annualTurnover": "10-20 Lakhs"
              },
              "description": "Dynamic survey form data submitted by the Channel Partner."
            },
            "photos": {
              "example": [
                "https://example.com/uploads/shop1.jpg",
                "https://example.com/uploads/shop2.jpg"
              ],
              "description": "List of uploaded survey photo URLs.",
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "gpsLat": {
              "type": "number",
              "example": 15.364708,
              "description": "Latitude captured during survey."
            },
            "gpsLng": {
              "type": "number",
              "example": 75.124001,
              "description": "Longitude captured during survey."
            },
            "gpsAccuracyMeters": {
              "type": "number",
              "example": 4,
              "description": "GPS accuracy in meters."
            },
            "deviceTimestamp": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-17T10:30:45.000Z",
              "description": "Device timestamp when the survey was submitted."
            }
          },
          "required": [
            "localId",
            "cpId",
            "submissionData",
            "deviceTimestamp"
          ]
        },
        "UpdateCpSurveyDto": {
          "type": "object",
          "properties": {
            "localId": {
              "type": "string"
            },
            "cpId": {
              "type": "string"
            },
            "submissionData": {
              "type": "object"
            },
            "photos": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "gpsLat": {
              "type": "number"
            },
            "gpsLng": {
              "type": "number"
            },
            "gpsAccuracyMeters": {
              "type": "number"
            },
            "deviceTimestamp": {
              "format": "date-time",
              "type": "string"
            }
          }
        },
        "CreateLeadDto": {
          "type": "object",
          "properties": {
            "leadName": {
              "type": "string",
              "description": "Lead Name",
              "example": "Ramesh Kumar"
            },
            "mobile": {
              "type": "string",
              "description": "Mobile Number",
              "example": "9876543210"
            },
            "businessCategoryId": {
              "type": "string",
              "description": "Business Category Id",
              "example": "2d3c6a89-8d4a-4dbe-a4cb-12f2c2fd6d91"
            },
            "source": {
              "type": "string",
              "description": "Lead Source",
              "example": "Website"
            },
            "assignCpId": {
              "type": "string",
              "description": "Assigned Channel Partner Id",
              "example": "8e73a0d5-7b64-4d74-8cf5-f5d8e0c1e542"
            },
            "chapterId": {
              "type": "string",
              "description": "Chapter Id",
              "example": "b4b7d42c-f4d7-4d38-9d18-54dc89fd1b65"
            },
            "districtId": {
              "type": "string",
              "description": "District Id",
              "example": "f94e07c3-2e95-4e15-bfe2-3c45f9d3a4d1"
            },
            "stage": {
              "type": "string",
              "description": "Lead Stage",
              "example": "new_lead",
              "default": "new_lead"
            },
            "estimatedValue": {
              "type": "number",
              "description": "Estimated Business Value (INR)",
              "example": 350000
            },
            "followUpAt": {
              "format": "date-time",
              "type": "string",
              "description": "Follow-up Date",
              "example": "2026-07-20T10:30:00.000Z"
            },
            "convertedMemberId": {
              "type": "string",
              "description": "Converted Member Id",
              "example": "f65aaf92-d2a6-4fd1-a5f3-93d4f61e7d25"
            },
            "createdByUserId": {
              "type": "string",
              "description": "Created By User Id",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1"
            }
          },
          "required": [
            "leadName",
            "mobile",
            "source",
            "createdByUserId"
          ]
        },
        "CreateLeadActivityDto": {
          "type": "object",
          "properties": {
            "leadId": {
              "type": "string",
              "example": "d8d2d4c1-3d11-4d0d-9b45-5b9f77d11234",
              "description": "Lead UUID"
            },
            "activityType": {
              "type": "string",
              "example": "stage_changed",
              "description": "Activity type (stage_changed, note_added, file_uploaded, call, meeting)"
            },
            "fromStage": {
              "type": "string",
              "example": "new",
              "description": "Previous lead stage"
            },
            "toStage": {
              "type": "string",
              "example": "contacted",
              "description": "Updated lead stage"
            },
            "noteText": {
              "type": "string",
              "example": "Customer requested a callback tomorrow at 11:00 AM.",
              "description": "Notes about the activity"
            },
            "fileUrl": {
              "type": "string",
              "example": "https://cdn.udyami.com/uploads/lead-documents/quotation.pdf",
              "description": "Uploaded file URL"
            },
            "performedByUserId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "User UUID who performed this activity"
            }
          },
          "required": [
            "leadId",
            "activityType",
            "performedByUserId"
          ]
        },
        "UpdateLeadActivityDto": {
          "type": "object",
          "properties": {
            "leadId": {
              "type": "string",
              "example": "d8d2d4c1-3d11-4d0d-9b45-5b9f77d11234",
              "description": "Lead UUID"
            },
            "activityType": {
              "type": "string",
              "example": "stage_changed",
              "description": "Activity type (stage_changed, note_added, file_uploaded, call, meeting)"
            },
            "fromStage": {
              "type": "string",
              "example": "new",
              "description": "Previous lead stage"
            },
            "toStage": {
              "type": "string",
              "example": "contacted",
              "description": "Updated lead stage"
            },
            "noteText": {
              "type": "string",
              "example": "Customer requested a callback tomorrow at 11:00 AM.",
              "description": "Notes about the activity"
            },
            "fileUrl": {
              "type": "string",
              "example": "https://cdn.udyami.com/uploads/lead-documents/quotation.pdf",
              "description": "Uploaded file URL"
            },
            "performedByUserId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "User UUID who performed this activity"
            }
          }
        },
        "CreatePaymentUdyamiDto": {
          "type": "object",
          "properties": {
            "invoiceNumber": {
              "type": "string",
              "description": "Invoice Number",
              "example": "INV-2026-0001"
            },
            "memberId": {
              "type": "string",
              "description": "Member Id",
              "example": "7b4a2a8c-5a31-4e2c-a5d4-9d7c6f2f8a91"
            },
            "amountRs": {
              "type": "number",
              "description": "Base Amount",
              "example": 999
            },
            "paymentMode": {
              "type": "string",
              "description": "Payment Mode",
              "example": "UPI"
            },
            "txnReference": {
              "type": "string",
              "description": "Transaction Reference",
              "example": "UPI202607170001"
            },
            "razorpayOrderId": {
              "type": "string",
              "description": "Razorpay Order Id",
              "example": "order_QxA7n2R8VhD4eF"
            },
            "razorpayPaymentId": {
              "type": "string",
              "description": "Razorpay Payment Id",
              "example": "pay_QxA8X9wL2nK7Qp"
            },
            "status": {
              "type": "string",
              "description": "Payment Status",
              "default": "pending",
              "example": "success"
            },
            "paymentFor": {
              "type": "string",
              "description": "Payment For",
              "default": "membership",
              "example": "membership"
            },
            "membershipFrom": {
              "format": "date-time",
              "type": "string",
              "description": "Membership Start Date",
              "example": "2026-07-17T00:00:00.000Z"
            },
            "membershipTo": {
              "format": "date-time",
              "type": "string",
              "description": "Membership End Date",
              "example": "2027-07-16T23:59:59.000Z"
            },
            "invoiceUrl": {
              "type": "string",
              "description": "Invoice URL",
              "example": "https://example.com/invoices/INV-2026-0001.pdf"
            },
            "waiverId": {
              "type": "string",
              "description": "Waiver Id",
              "example": "2f9c1d0d-2d5b-4bcb-8e4a-7d9b0c5c3d88"
            },
            "originalAmount": {
              "type": "number",
              "description": "Original Amount",
              "example": 1200
            },
            "createdByUserId": {
              "type": "string",
              "description": "Created By User Id",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1"
            }
          },
          "required": [
            "invoiceNumber",
            "memberId",
            "amountRs",
            "paymentMode",
            "createdByUserId"
          ]
        },
        "CreateCampaignDto": {
          "type": "object",
          "properties": {
            "platform": {
              "type": "string",
              "example": "udyami",
              "description": "Campaign platform"
            },
            "name": {
              "type": "string",
              "example": "Membership Drive",
              "description": "Campaign name"
            },
            "channel": {
              "type": "string",
              "example": "whatsapp",
              "description": "Communication channel"
            },
            "templateId": {
              "type": "string",
              "example": "2c1f95d0-6b91-4d2e-8f1c-7df9d2c54b11",
              "description": "Template UUID"
            },
            "audioId": {
              "type": "string",
              "example": "1fd80cb8-2f7f-41d5-b8bb-3e6355b57a77",
              "description": "Audio UUID"
            },
            "audienceType": {
              "type": "string",
              "example": "ward",
              "description": "Audience type"
            },
            "audienceFilters": {
              "type": "object",
              "example": {
                "state": "Karnataka",
                "district": "Dharwad",
                "assembly": "Hubli-Dharwad East",
                "ward": "Ward 5",
                "role": "ChannelPartner"
              },
              "description": "Audience filtering criteria"
            },
            "audienceCount": {
              "type": "number",
              "example": 1500,
              "description": "Total audience count"
            },
            "variableMap": {
              "type": "object",
              "example": {
                "userName": "name",
                "mobileNumber": "mobile",
                "wardName": "ward"
              },
              "description": "Dynamic template variable mapping"
            },
            "scheduleType": {
              "type": "string",
              "example": "immediate",
              "description": "Campaign execution type",
              "default": "immediate"
            },
            "scheduleAt": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-20T10:00:00.000Z",
              "description": "Scheduled execution time"
            },
            "status": {
              "type": "string",
              "example": "draft",
              "description": "Campaign status",
              "default": "draft"
            },
            "bullJobId": {
              "type": "string",
              "example": "campaign-job-001",
              "description": "Bull Queue Job ID"
            },
            "launchedAt": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-20T10:00:05.000Z",
              "description": "Campaign launch timestamp"
            },
            "completedAt": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-20T10:45:30.000Z",
              "description": "Campaign completion timestamp"
            },
            "createdByUserId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "UUID of the user who created the campaign"
            }
          },
          "required": [
            "platform",
            "name",
            "channel",
            "audienceType",
            "createdByUserId"
          ]
        },
        "CreateMemberPointDto": {
          "type": "object",
          "properties": {
            "memberId": {
              "type": "string",
              "example": "7b4a2a8c-5a31-4e2c-a5d4-9d7c6f2f8a91",
              "description": "Member UUID"
            },
            "points": {
              "type": "number",
              "example": 100,
              "description": "Points to be added or deducted"
            },
            "actionType": {
              "type": "string",
              "example": "survey_submission",
              "description": "Type of action (survey_submission, referral, registration_bonus, purchase, redemption)"
            },
            "referenceId": {
              "type": "string",
              "example": "3d7b0d7e-9d1f-4f52-bb7d-4d2d6d8d1a4f",
              "description": "Reference entity UUID (Survey ID, Campaign ID, etc.)"
            },
            "reason": {
              "type": "string",
              "example": "Points awarded for completing Ward Survey.",
              "description": "Reason for point transaction"
            },
            "expiresAt": {
              "format": "date-time",
              "type": "string",
              "example": "2027-12-31T23:59:59.000Z",
              "description": "Point expiry date (optional)"
            },
            "createdBySystem": {
              "type": "boolean",
              "example": true,
              "default": true,
              "description": "Whether the points were created by the system"
            }
          },
          "required": [
            "memberId",
            "points",
            "actionType",
            "reason"
          ]
        },
        "UpdateMemberPointDto": {
          "type": "object",
          "properties": {
            "memberId": {
              "type": "string",
              "example": "7b4a2a8c-5a31-4e2c-a5d4-9d7c6f2f8a91",
              "description": "Member UUID"
            },
            "points": {
              "type": "number",
              "example": 100,
              "description": "Points to be added or deducted"
            },
            "actionType": {
              "type": "string",
              "example": "survey_submission",
              "description": "Type of action (survey_submission, referral, registration_bonus, purchase, redemption)"
            },
            "referenceId": {
              "type": "string",
              "example": "3d7b0d7e-9d1f-4f52-bb7d-4d2d6d8d1a4f",
              "description": "Reference entity UUID (Survey ID, Campaign ID, etc.)"
            },
            "reason": {
              "type": "string",
              "example": "Points awarded for completing Ward Survey.",
              "description": "Reason for point transaction"
            },
            "expiresAt": {
              "format": "date-time",
              "type": "string",
              "example": "2027-12-31T23:59:59.000Z",
              "description": "Point expiry date (optional)"
            },
            "createdBySystem": {
              "type": "boolean",
              "example": true,
              "default": true,
              "description": "Whether the points were created by the system"
            }
          }
        },
        "CreateReferralDto": {
          "type": "object",
          "properties": {
            "chapterId": {
              "type": "string",
              "example": "3c5b4c8e-2c49-4d0d-a4c8-9b4e8d3a1f55",
              "description": "Chapter Id"
            },
            "giverMemberId": {
              "type": "string",
              "example": "9bafc0d3-8f4d-45a6-90d1-c8b45a5e2141",
              "description": "Giver Member Id"
            },
            "receiverMemberId": {
              "type": "string",
              "example": "b6d3d5c1-7c44-4f11-b7c9-15b96d5f98d0",
              "description": "Receiver Member Id"
            },
            "referredPersonName": {
              "type": "string",
              "example": "Ravi Kumar",
              "description": "Referred Person Name"
            },
            "referredPersonMobile": {
              "type": "string",
              "example": "9876543210",
              "description": "Referred Person Mobile Number"
            },
            "businessType": {
              "type": "string",
              "example": "Interior Design",
              "description": "Business Type"
            },
            "estimatedValueRs": {
              "type": "number",
              "example": 250000,
              "description": "Estimated Business Value (INR)"
            },
            "status": {
              "type": "string",
              "example": "pending",
              "description": "Referral Status",
              "default": "pending"
            },
            "tyfcbAmountRs": {
              "type": "number",
              "example": 5000,
              "description": "TYFCB Amount (INR)"
            },
            "tyfcbDate": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-17T10:30:00.000Z",
              "description": "TYFCB Payment Date"
            }
          },
          "required": [
            "chapterId",
            "giverMemberId",
            "receiverMemberId",
            "referredPersonName"
          ]
        },
        "UpdateReferralDto": {
          "type": "object",
          "properties": {
            "chapterId": {
              "type": "string",
              "example": "3c5b4c8e-2c49-4d0d-a4c8-9b4e8d3a1f55",
              "description": "Chapter Id"
            },
            "giverMemberId": {
              "type": "string",
              "example": "9bafc0d3-8f4d-45a6-90d1-c8b45a5e2141",
              "description": "Giver Member Id"
            },
            "receiverMemberId": {
              "type": "string",
              "example": "b6d3d5c1-7c44-4f11-b7c9-15b96d5f98d0",
              "description": "Receiver Member Id"
            },
            "referredPersonName": {
              "type": "string",
              "example": "Ravi Kumar",
              "description": "Referred Person Name"
            },
            "referredPersonMobile": {
              "type": "string",
              "example": "9876543210",
              "description": "Referred Person Mobile Number"
            },
            "businessType": {
              "type": "string",
              "example": "Interior Design",
              "description": "Business Type"
            },
            "estimatedValueRs": {
              "type": "number",
              "example": 250000,
              "description": "Estimated Business Value (INR)"
            },
            "status": {
              "type": "string",
              "example": "pending",
              "description": "Referral Status",
              "default": "pending"
            },
            "tyfcbAmountRs": {
              "type": "number",
              "example": 5000,
              "description": "TYFCB Amount (INR)"
            },
            "tyfcbDate": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-17T10:30:00.000Z",
              "description": "TYFCB Payment Date"
            }
          }
        },
        "CreateGpsPingDto": {
          "type": "object",
          "properties": {
            "platform": {
              "type": "string",
              "example": "udyami",
              "description": "Platform name"
            },
            "agentUserId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "Agent/User UUID"
            },
            "lat": {
              "type": "number",
              "example": 18.5204303,
              "description": "Latitude"
            },
            "lng": {
              "type": "number",
              "example": 73.8567437,
              "description": "Longitude"
            },
            "accuracyMeters": {
              "type": "number",
              "example": 4,
              "description": "GPS accuracy in meters"
            }
          },
          "required": [
            "platform",
            "agentUserId",
            "lat",
            "lng"
          ]
        },
        "UpdateGpsPingDto": {
          "type": "object",
          "properties": {
            "platform": {
              "type": "string",
              "example": "udyami",
              "description": "Platform name"
            },
            "agentUserId": {
              "type": "string",
              "example": "12eed791-ce9d-49d7-9e47-5eb58c181de1",
              "description": "Agent/User UUID"
            },
            "lat": {
              "type": "number",
              "example": 18.5204303,
              "description": "Latitude"
            },
            "lng": {
              "type": "number",
              "example": 73.8567437,
              "description": "Longitude"
            },
            "accuracyMeters": {
              "type": "number",
              "example": 4,
              "description": "GPS accuracy in meters"
            }
          }
        },
        "UpdateWardDto": {
          "type": "object",
          "properties": {
            "wardName": {
              "type": "string",
              "example": "Ward 12"
            },
            "district": {
              "type": "string",
              "example": "Bengaluru Urban"
            },
            "taluka": {
              "type": "string",
              "example": "Bangalore North"
            },
            "talukaId": {
              "type": "string",
              "example": "c76e9507-df13-4614-bc46-7fc4fdde97f3"
            },
            "state": {
              "type": "string",
              "example": "Karnataka"
            },
            "wardNumber": {
              "type": "string",
              "example": "23"
            },
            "geoJson": {
              "type": "object",
              "description": "Ward GeoJSON"
            }
          }
        },
        "CreateUserProfileDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "7d5b5f2a-2c6d-4d42-b5f8-2e4d5d4b8a91",
              "description": "User Id"
            },
            "alternateMobile": {
              "type": "string",
              "example": "9876543210",
              "description": "Alternate Mobile Number"
            },
            "gender": {
              "type": "string",
              "example": "Male",
              "description": "Gender"
            },
            "state": {
              "type": "string",
              "example": "Karnataka",
              "description": "State"
            },
            "district": {
              "type": "string",
              "example": "Bengaluru Urban",
              "description": "District"
            },
            "assembly": {
              "type": "string",
              "example": "Mahadevapura",
              "description": "Assembly Constituency"
            },
            "ward": {
              "type": "string",
              "example": "Ward 150",
              "description": "Ward"
            },
            "pincode": {
              "type": "string",
              "example": "560037",
              "description": "Pincode"
            },
            "homeAddress": {
              "type": "string",
              "example": "No. 45, Whitefield Main Road, Bengaluru",
              "description": "Home Address"
            },
            "officeAddress": {
              "type": "string",
              "example": "ITPL Tech Park, Whitefield, Bengaluru",
              "description": "Office Address"
            },
            "hasBusiness": {
              "type": "boolean",
              "example": true,
              "description": "Whether the user owns a business"
            },
            "businessDetails": {
              "type": "string",
              "description": "Business Details as JSON string",
              "example": "{\"sector\":\"Retail\",\"businessName\":\"Sri Lakshmi Traders\",\"businessType\":\"Wholesale Grocery\",\"gstNumber\":\"29ABCDE1234F1Z5\",\"registrationNumber\":\"REG20260001\",\"ownerName\":\"Ramesh Kumar\",\"establishedYear\":2019,\"employees\":12,\"annualTurnover\":\"1.2 Crore\",\"address\":\"No. 18, Commercial Street\",\"city\":\"Bengaluru\",\"district\":\"Bengaluru Urban\",\"state\":\"Karnataka\",\"pincode\":\"560001\",\"latitude\":12.9784,\"longitude\":77.6408,\"website\":\"https://srilakshmitraders.in\",\"email\":\"info@srilakshmitraders.in\",\"businessMobile\":\"9988776655\"}"
            },
            "profileImage": {
              "type": "string",
              "format": "binary",
              "description": "Profile Image"
            },
            "businessImages": {
              "type": "array",
              "items": {
                "type": "string",
                "format": "binary"
              },
              "description": "Upload up to 3 Business Images"
            },
            "selectedBusinessVertical": {
              "type": "string",
              "example": "Bhoomi Vault",
              "description": "Selected Business Vertical"
            }
          },
          "required": [
            "userId"
          ]
        },
        "SearchUserDto": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "example": "Ramesh"
            },
            "ward": {
              "type": "string",
              "example": "Ward 15"
            },
            "talukaId": {
              "type": "string",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            },
            "districtId": {
              "type": "string",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            }
          }
        },
        "UpdateUserProfileDto": {
          "type": "object",
          "properties": {
            "alternateMobile": {
              "type": "string",
              "example": "9876543210"
            },
            "gender": {
              "type": "string",
              "example": "Male"
            },
            "state": {
              "type": "string",
              "example": "Karnataka"
            },
            "district": {
              "type": "string",
              "example": "Bengaluru Urban"
            },
            "assembly": {
              "type": "string",
              "example": "Yeshwanthpur"
            },
            "ward": {
              "type": "string",
              "example": "Ward 12"
            },
            "pincode": {
              "type": "string",
              "example": "560001"
            },
            "homeAddress": {
              "type": "string",
              "example": "123, Main Road, Bengaluru"
            },
            "officeAddress": {
              "type": "string",
              "example": "456, Business Road, Bengaluru"
            },
            "cityOfResidence": {
              "type": "string",
              "example": "Bengaluru"
            },
            "yearsInCity": {
              "type": "number",
              "example": 10
            },
            "hasBusiness": {
              "type": "boolean",
              "example": true
            },
            "businessDetails": {
              "type": "object",
              "example": {
                "businessName": "ABC Enterprises",
                "businessType": "Retail",
                "businessAddress": "Bengaluru"
              }
            },
            "selectedBusinessVertical": {
              "type": "string",
              "example": "Finance & Investment"
            },
            "profileImage": {
              "type": "string",
              "description": "Profile image as Base64 string or image URL"
            },
            "familyInformation": {
              "type": "string",
              "example": "Lives with spouse and two children."
            },
            "spouse": {
              "type": "string",
              "example": "Priya"
            },
            "children": {
              "type": "string",
              "example": "Son - Rahul, Daughter - Ananya"
            },
            "pets": {
              "type": "string",
              "example": "Dog - Bruno"
            },
            "hobbies": {
              "type": "string",
              "example": "Reading, Travelling, Cricket"
            },
            "activitiesOrInterests": {
              "type": "string",
              "example": "Community activities and social events"
            }
          }
        },
        "CreateBusinessVerticalDto": {
          "type": "object",
          "properties": {
            "verticalName": {
              "type": "string",
              "example": "Bhoomi Vault"
            },
            "description": {
              "type": "string",
              "example": "Property investment vertical"
            },
            "displayOrder": {
              "type": "number",
              "example": 1
            },
            "isActive": {
              "type": "boolean",
              "example": true
            }
          },
          "required": [
            "verticalName"
          ]
        },
        "AssignTalukasToDistrictDto": {
          "type": "object",
          "properties": {
            "districtId": {
              "type": "string"
            },
            "talukaIds": {
              "type": "array",
              "items": {
                "type": "string"
              }
            }
          },
          "required": [
            "districtId",
            "talukaIds"
          ]
        },
        "AssignWardsToTalukaDto": {
          "type": "object",
          "properties": {
            "talukaId": {
              "type": "string"
            },
            "wardIds": {
              "type": "array",
              "items": {
                "type": "string"
              }
            }
          },
          "required": [
            "talukaId",
            "wardIds"
          ]
        },
        "CreateDistrictDto": {
          "type": "object",
          "properties": {
            "districtName": {
              "type": "string",
              "example": "Pune",
              "description": "District name"
            },
            "state": {
              "type": "string",
              "example": "Maharashtra",
              "description": "State name"
            },
            "districtBoundary": {
              "type": "object",
              "description": "District boundary in GeoJSON format",
              "example": {
                "type": "Polygon",
                "coordinates": [
                  [
                    [
                      73.8567,
                      18.5204
                    ],
                    [
                      73.9654,
                      18.6123
                    ],
                    [
                      74.0234,
                      18.4532
                    ],
                    [
                      73.8567,
                      18.5204
                    ]
                  ]
                ]
              }
            }
          },
          "required": [
            "districtName",
            "state"
          ]
        },
        "AdminAssignDistrictHeadDto": {
          "type": "object",
          "properties": {
            "districtId": {
              "type": "string",
              "example": "b2e5c9a8-4e5d-4f83-9b85-6c9d5f8a1234",
              "description": "District Id"
            },
            "districtHeadId": {
              "type": "string",
              "example": "8d3c1f2a-7b91-4b6d-95d1-9d5a4d6c5678",
              "description": "District Head User Id"
            },
            "assignedBy": {
              "type": "string",
              "example": "f4b7d8c9-3a6e-4b5a-9c8d-7e6f5a4b3c21",
              "description": "Super Admin User Id who assigned the district"
            }
          },
          "required": [
            "districtId",
            "districtHeadId",
            "assignedBy"
          ]
        },
        "CreateTalukaDto": {
          "type": "object",
          "properties": {
            "talukaName": {
              "type": "string",
              "example": "Haveli"
            },
            "districtId": {
              "type": "string",
              "example": "7d7d68e6-5a6d-47d2-a6f1-45d0b69d4c8b",
              "description": "District ID"
            },
            "talukaBoundary": {
              "type": "object",
              "description": "Taluka boundary in GeoJSON format",
              "example": {
                "type": "Polygon",
                "coordinates": [
                  [
                    [
                      73.8567,
                      18.5204
                    ],
                    [
                      73.9654,
                      18.6123
                    ],
                    [
                      74.0234,
                      18.4532
                    ],
                    [
                      73.8567,
                      18.5204
                    ]
                  ]
                ]
              }
            }
          },
          "required": [
            "talukaName",
            "districtId"
          ]
        },
        "AssignWardDto": {
          "type": "object",
          "properties": {
            "talukaHeadId": {
              "type": "string",
              "example": "8d7d0f2f-7a9f-4d5b-a3f9-1b2c3d4e5f67",
              "description": "Taluka Head User ID"
            },
            "wardHeadId": {
              "type": "string",
              "example": "4f9b8c7d-2a1e-4b6c-9d8f-7a6b5c4d3e2f",
              "description": "Ward Head User ID"
            },
            "talukaId": {
              "type": "string",
              "example": "7c4e2b18-45f8-4e6d-a17d-9c4d1b2a3456",
              "description": "Taluka ID"
            },
            "wardId": {
              "type": "string",
              "example": "c2f1e3d4-5b6a-47d8-9c0b-1a2b3c4d5e6f",
              "description": "Ward ID"
            }
          },
          "required": [
            "talukaHeadId",
            "wardHeadId",
            "talukaId",
            "wardId"
          ]
        },
        "AssignDesignationDto": {
          "type": "object",
          "properties": {
            "designationId": {
              "type": "string",
              "example": "designation-uuid"
            },
            "userId": {
              "type": "string",
              "example": "user-uuid"
            },
            "circleLeaderId": {
              "type": "string",
              "example": "circle-leader-uuid"
            },
            "wardId": {
              "type": "string",
              "example": "ward-uuid"
            }
          },
          "required": [
            "designationId",
            "userId",
            "circleLeaderId",
            "wardId"
          ]
        },
        "ReplaceDesignationHolderDto": {
          "type": "object",
          "properties": {
            "designationId": {
              "type": "string",
              "description": "Designation ID",
              "example": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
            },
            "wardId": {
              "type": "string",
              "description": "Ward ID",
              "example": "9c2d5e1a-5c0d-4c6b-a8d3-5d8d9b3e7f90"
            },
            "oldUserId": {
              "type": "string",
              "description": "Current designation holder user ID",
              "example": "7d9c5d84-8f6f-4b89-9f8b-4baf0d9e2c31"
            },
            "newUserId": {
              "type": "string",
              "description": "New designation holder user ID",
              "example": "5f7a6d21-4b1e-48f5-93b2-2b5d4d1e8c73"
            },
            "circleLeaderId": {
              "type": "string",
              "description": "Circle Leader ID",
              "example": "2d5d7b4d-1b7e-4d8d-bcf4-8a0d2f8b5b21"
            }
          },
          "required": [
            "designationId",
            "wardId",
            "oldUserId",
            "newUserId",
            "circleLeaderId"
          ]
        },
        "AddCoinsDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "description": "User ID of the wallet owner",
              "example": "7df98dcb-3b4c-48d4-93fc-4d8f33c54a1e"
            },
            "coins": {
              "type": "number",
              "description": "Number of coins to add",
              "example": 500,
              "minimum": 1
            }
          },
          "required": [
            "userId",
            "coins"
          ]
        },
        "RenderEmailDto": {
          "type": "object",
          "properties": {
            "email": {
              "type": "string",
              "example": "abc@gmail.com"
            },
            "memberId": {
              "type": "string",
              "example": "7df98dcb-xxxx"
            },
            "templateId": {
              "type": "string",
              "example": "b8b3b74c-xxxx"
            }
          },
          "required": [
            "email",
            "memberId",
            "templateId"
          ]
        },
        "CreateBulkCampaignDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "e720aad8-f353-4710-be29-27a8b3a01ca7"
            },
            "channel": {
              "type": "string",
              "enum": [
                "EMAIL",
                "SMS",
                "WHATSAPP",
                "IVR"
              ],
              "example": "EMAIL"
            },
            "templateId": {
              "type": "string",
              "example": "65a1d9f4b9876543210fedcb"
            },
            "memberIds": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "uploadIds": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "scheduledAt": {
              "type": "string",
              "example": "2026-07-25T10:30:00+05:30",
              "description": "Campaign scheduled date and time"
            },
            "voiceFileId": {
              "type": "string",
              "example": "b1e2c3d4-e5f6-47a8-89b0-1234567890ab",
              "description": "Voice file to attach for IVR campaigns"
            }
          },
          "required": [
            "userId",
            "channel",
            "scheduledAt"
          ]
        },
        "ReviewUploadDto": {
          "type": "object",
          "properties": {
            "campaignId": {
              "type": "string",
              "example": "35e8df87-ad36-45ed-91ee-b90cea787c57"
            },
            "adminUserId": {
              "type": "string",
              "example": "c4c23b61-1db6-4b42-8d59-fd90b4d8d421"
            },
            "status": {
              "type": "string",
              "enum": [
                "PENDING",
                "APPROVED",
                "REJECTED",
                "COMPLETED"
              ],
              "example": "APPROVED"
            },
            "remark": {
              "type": "string",
              "example": "Verified successfully"
            }
          },
          "required": [
            "campaignId",
            "adminUserId",
            "status"
          ]
        },
        "SendSmsDto": {
          "type": "object",
          "properties": {
            "to": {
              "type": "string",
              "example": "+919876543210",
              "description": "Recipient mobile number in E.164 format"
            },
            "message": {
              "type": "string",
              "example": "Hello Suraj, Welcome to Udyami Circle!"
            }
          },
          "required": [
            "to",
            "message"
          ]
        },
        "SendBulkCampaignDto": {
          "type": "object",
          "properties": {
            "campaignId": {
              "type": "string",
              "example": "86befec9-f6ff-4410-a07d-95eb770dc2c0",
              "description": "Campaign ID"
            }
          },
          "required": [
            "campaignId"
          ]
        },
        "CreateMeetingDto": {
          "type": "object",
          "properties": {
            "date": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30T10:00:00.000Z"
            },
            "venue": {
              "type": "string",
              "example": "Pune BNI Office"
            },
            "agenda": {
              "type": "string",
              "example": "Weekly BNI Business Networking Meeting"
            },
            "status": {
              "type": "string",
              "example": "Scheduled"
            },
            "talukaId": {
              "type": "string",
              "example": "eda1b264-0525-4cf1-857b-59a64cb7f816",
              "description": "Optional Taluka ID"
            },
            "wardId": {
              "type": "string",
              "example": "f4da9730-8345-44e9-94f2-7b173448eb73",
              "description": "Optional Ward ID"
            }
          },
          "required": [
            "date",
            "venue",
            "agenda",
            "status"
          ]
        },
        "UpdateMeetingDto": {
          "type": "object",
          "properties": {
            "date": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30T10:00:00.000Z"
            },
            "venue": {
              "type": "string",
              "example": "Pune BNI Office"
            },
            "agenda": {
              "type": "string",
              "example": "Weekly Business Meeting"
            },
            "status": {
              "type": "string",
              "example": "Completed"
            }
          }
        },
        "UpdateMeetingRsvpDto": {
          "type": "object",
          "properties": {
            "meetingId": {
              "type": "string",
              "example": "2b89b8d6-f6d0-4d4b-9c8d-6f5d8d4b1234"
            },
            "status": {
              "type": "string",
              "enum": [
                "Pending",
                "Accepted",
                "Declined",
                "Maybe"
              ],
              "example": "Accepted"
            }
          },
          "required": [
            "meetingId",
            "status"
          ]
        },
        "SearchMemberDto": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "example": "Suraj"
            },
            "sector": {
              "type": "string",
              "example": "IT"
            },
            "subSector": {
              "type": "string",
              "example": "Software Development"
            }
          },
          "required": [
            "name"
          ]
        },
        "CreateBniLeadDto": {
          "type": "object",
          "properties": {
            "memberName": {
              "type": "string",
              "example": "Rahul Sharma",
              "description": "Name of the member who referred the lead"
            },
            "category": {
              "type": "string",
              "example": "IT Services",
              "description": "Business category"
            },
            "leadType": {
              "type": "string",
              "example": "Referral",
              "description": "Type of lead"
            },
            "business": {
              "type": "string",
              "example": "ABC Technologies Pvt Ltd",
              "description": "Business name"
            },
            "phone": {
              "type": "string",
              "example": "9876543210",
              "description": "Contact phone number"
            },
            "heatLevel": {
              "type": "string",
              "example": "Hot",
              "description": "Lead priority (Hot, Warm, Cold)"
            },
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "UUID of the user who created the lead"
            },
            "status": {
              "type": "string",
              "example": "Pending",
              "description": "Lead status"
            },
            "feedback": {
              "type": "string",
              "example": "Customer is interested in ERP software.",
              "description": "Feedback about the lead"
            },
            "message": {
              "type": "string",
              "example": "Follow up next Monday after 11 AM.",
              "description": "Additional message or notes"
            }
          },
          "required": [
            "memberName",
            "category",
            "leadType",
            "business",
            "phone",
            "heatLevel",
            "createdUserId"
          ]
        },
        "UpdateLeadStatusDto": {
          "type": "object",
          "properties": {
            "status": {
              "type": "string",
              "example": "Converted",
              "description": "Updated status of the lead"
            },
            "userId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "UUID of the user updating the lead status"
            }
          },
          "required": [
            "status",
            "userId"
          ]
        },
        "GetLeadsByUserDto": {
          "type": "object",
          "properties": {
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Created User ID"
            }
          },
          "required": [
            "createdUserId"
          ]
        },
        "CreateFaceToFaceDto": {
          "type": "object",
          "properties": {
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "User who is creating the meeting"
            },
            "invitedMemberUserId": {
              "type": "string",
              "example": "2df65e4a-03e7-4e90-bf0f-d8db3ecb91b7",
              "description": "Invited member User ID"
            },
            "date": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30",
              "description": "Meeting date"
            },
            "purpose": {
              "type": "string",
              "example": "Business Networking",
              "description": "Purpose of the meeting"
            },
            "businessName": {
              "type": "string",
              "example": "ABC Enterprises",
              "description": "Business name"
            },
            "profession": {
              "type": "string",
              "example": "Business Consultant",
              "description": "Current profession"
            },
            "location": {
              "type": "string",
              "example": "Hubballi, Karnataka",
              "description": "Business or professional location"
            },
            "yearsInBusiness": {
              "type": "number",
              "example": 8,
              "description": "Number of years in business"
            },
            "previousJobs": {
              "type": "string",
              "example": "Sales Manager, Marketing Executive",
              "description": "Previous types of jobs"
            },
            "familyInformation": {
              "type": "string",
              "example": "Lives with spouse and two children",
              "description": "General family information"
            },
            "spouse": {
              "type": "string",
              "example": "Priya Sharma",
              "description": "Spouse name"
            },
            "children": {
              "type": "string",
              "example": "Two children - son aged 10 and daughter aged 7",
              "description": "Children information"
            },
            "pets": {
              "type": "string",
              "example": "One Labrador dog",
              "description": "Pets information"
            },
            "hobbies": {
              "type": "string",
              "example": "Travelling, Cricket, Reading",
              "description": "Hobbies"
            },
            "activitiesOrInterests": {
              "type": "string",
              "example": "Networking events, Community activities",
              "description": "Activities or interests"
            },
            "cityOfResidence": {
              "type": "string",
              "example": "Hubballi",
              "description": "City of residence"
            },
            "yearsInCity": {
              "type": "number",
              "example": 12,
              "description": "Number of years living in the city"
            },
            "status": {
              "type": "string",
              "example": "Pending",
              "description": "Meeting status"
            },
            "feedback": {
              "type": "string",
              "example": "Great discussion about business opportunities.",
              "description": "Feedback"
            },
            "message": {
              "type": "string",
              "example": "Looking forward to meeting.",
              "description": "Additional message"
            }
          },
          "required": [
            "createdUserId",
            "invitedMemberUserId",
            "date"
          ]
        },
        "UpdateFaceToFaceStatusDto": {
          "type": "object",
          "properties": {
            "invitedMemberUserId": {
              "type": "string",
              "example": "1a0d56f3-68bd-4517-bf0f-1c0ea93157a4",
              "description": "Invited Member User ID"
            },
            "status": {
              "type": "string",
              "example": "Completed"
            },
            "feedback": {
              "type": "string",
              "example": "Meeting was successful."
            },
            "message": {
              "type": "string",
              "example": "Next meeting scheduled for next month."
            }
          },
          "required": [
            "invitedMemberUserId",
            "status"
          ]
        },
        "GetFaceToFaceByUserDto": {
          "type": "object",
          "properties": {
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Created User ID"
            }
          },
          "required": [
            "createdUserId"
          ]
        },
        "DeleteFaceToFaceDto": {
          "type": "object",
          "properties": {
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Created User ID"
            }
          },
          "required": [
            "createdUserId"
          ]
        },
        "CreateContactSphereDto": {
          "type": "object",
          "properties": {
            "meetingId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Face-to-face meeting ID"
            },
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "User who created the meeting"
            },
            "invitedMemberUserId": {
              "type": "string",
              "example": "2df65e4a-03e7-4e90-bf0f-d8db3ecb91b7",
              "description": "Invited member user ID"
            },
            "contactSphereName": {
              "type": "string",
              "example": "Real Estate Professionals",
              "description": "Contact Sphere name"
            },
            "contactSphereMembers": {
              "example": [
                {
                  "name": "Rajesh Kumar",
                  "profession": "Real Estate"
                },
                {
                  "name": "Amit Sharma",
                  "profession": "Chartered Accountant"
                }
              ],
              "description": "Existing members in the Contact Sphere",
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "profession1": {
              "type": "string",
              "example": "Real Estate Lawyer",
              "description": "Top profession 1"
            },
            "profession2": {
              "type": "string",
              "example": "Home Loan Consultant",
              "description": "Top profession 2"
            },
            "profession3": {
              "type": "string",
              "example": "Interior Designer",
              "description": "Top profession 3"
            },
            "commitment": {
              "type": "string",
              "example": "I will invite 3 people from my network to BNI.",
              "description": "Commitment made during the meeting"
            }
          },
          "required": [
            "meetingId",
            "createdUserId",
            "invitedMemberUserId"
          ]
        },
        "UpdateContactSphereDto": {
          "type": "object",
          "properties": {
            "contactSphereName": {
              "type": "string",
              "example": "Real Estate Professionals"
            },
            "contactSphereMembers": {
              "example": [
                {
                  "name": "Rajesh Kumar",
                  "profession": "Real Estate"
                },
                {
                  "name": "Amit Sharma",
                  "profession": "Chartered Accountant"
                }
              ],
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "profession1": {
              "type": "string",
              "example": "Real Estate Lawyer"
            },
            "profession2": {
              "type": "string",
              "example": "Home Loan Consultant"
            },
            "profession3": {
              "type": "string",
              "example": "Interior Designer"
            },
            "commitment": {
              "type": "string",
              "example": "I will invite 3 people from my network to BNI."
            }
          }
        },
        "CreateUcTrainingDto": {
          "type": "object",
          "properties": {
            "ytLink": {
              "type": "string",
              "example": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
              "description": "YouTube training video link"
            },
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Created User ID"
            }
          },
          "required": [
            "ytLink",
            "createdUserId"
          ]
        },
        "UpdateUcTrainingDto": {
          "type": "object",
          "properties": {
            "ytLink": {
              "type": "string",
              "example": "https://www.youtube.com/watch?v=abcd1234"
            }
          }
        },
        "UpdateGratitudeSlipDto": {
          "type": "object",
          "properties": {
            "thankYouMemberUserId": {
              "type": "string",
              "description": "User ID of the member being thanked",
              "example": "d787871d-1c38-4d31-bfcf-7e7d4e910600"
            },
            "leadId": {
              "type": "string",
              "description": "ID of the linked BNI Lead",
              "example": "fc7549fa-37dd-4abb-9ed9-6c795736f085"
            },
            "businessValue": {
              "type": "number",
              "description": "Business value generated from the lead",
              "example": 15000
            },
            "type": {
              "type": "string",
              "description": "Type of gratitude slip",
              "example": "Inside"
            },
            "createdUserId": {
              "type": "string",
              "description": "User ID of the creator",
              "example": "1c548273-3c6f-4076-8e79-e45e459cf8c4"
            },
            "feedback": {
              "type": "string",
              "description": "Feedback"
            },
            "proofImages": {
              "type": "array",
              "description": "Proof Images",
              "items": {
                "type": "string",
                "format": "binary"
              }
            },
            "utrNo": {
              "type": "string",
              "description": "UTR Number",
              "example": "HDFC202600012345"
            }
          }
        },
        "CreateGuestDto": {
          "type": "object",
          "properties": {
            "guestName": {
              "type": "string",
              "example": "Rahul Sharma",
              "description": "Guest Name"
            },
            "createdUserId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "Created User ID"
            },
            "status": {
              "type": "string",
              "example": "Pending"
            }
          },
          "required": [
            "guestName",
            "createdUserId"
          ]
        },
        "UpdateGuestDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "810bfb1d-7b0a-4584-bba5-ce9108078863",
              "description": "User updating the guest"
            },
            "guestName": {
              "type": "string",
              "example": "Rahul Sharma"
            },
            "status": {
              "type": "string",
              "example": "Visited"
            }
          },
          "required": [
            "userId"
          ]
        },
        "CreateHallBookingDto": {
          "type": "object",
          "properties": {
            "meetingId": {
              "type": "string",
              "example": "d7c7d962-3fd5-4ca3-b43f-f40e0b34cb36",
              "description": "Meeting ID"
            },
            "hallName": {
              "type": "string",
              "example": "Conference Hall A",
              "description": "Hall name"
            },
            "bookingDate": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30T10:00:00.000Z",
              "description": "Hall booking date and time"
            },
            "seats": {
              "type": "number",
              "example": 120,
              "description": "Number of seats"
            },
            "createdUserId": {
              "type": "string",
              "example": "cb0d6421-058a-4d99-ab17-7af77df332e4",
              "description": "User ID who created the booking"
            }
          },
          "required": [
            "meetingId",
            "hallName",
            "bookingDate",
            "seats",
            "createdUserId"
          ]
        },
        "UpdateHallBookingDto": {
          "type": "object",
          "properties": {
            "hallName": {
              "type": "string",
              "example": "Conference Hall B"
            },
            "bookingDate": {
              "format": "date-time",
              "type": "string",
              "example": "2026-08-01T14:00:00.000Z"
            },
            "seats": {
              "type": "number",
              "example": 150
            }
          }
        },
        "CreateSectorJoinRequestDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "description": "User ID of the member requesting the sector",
              "example": "7d68d9d5-1e3f-4c2d-9f80-95cf6d0a7f11"
            },
            "createdUserId": {
              "type": "string",
              "description": "User ID of the user who created the request",
              "example": "2f76c3d4-9b8d-4b29-bf8d-2346cf7d8911"
            },
            "sectorId": {
              "type": "string",
              "description": "Business Sector ID",
              "example": "90d5a81b-9db6-4632-9cf2-61c7a6cdd3f8"
            },
            "subSector": {
              "type": "string",
              "description": "Requested Sub Sector",
              "example": "Tiles & Granite",
              "maxLength": 150
            },
            "remarks": {
              "type": "string",
              "description": "Remarks for the sector join request",
              "example": "Interested in joining this sector."
            }
          },
          "required": [
            "userId",
            "createdUserId",
            "sectorId",
            "subSector"
          ]
        },
        "RejectSectorJoinRequestDto": {
          "type": "object",
          "properties": {
            "remarks": {
              "type": "string",
              "description": "Reason for rejecting the sector join request",
              "example": "This sector is already occupied by another member."
            }
          },
          "required": [
            "remarks"
          ]
        },
        "CreateBusinessTagDto": {
          "type": "object",
          "properties": {
            "tagName": {
              "type": "string",
              "example": "Angular",
              "description": "Name of the business tag"
            },
            "description": {
              "type": "string",
              "example": "Angular Development Services",
              "description": "Description of the business tag"
            },
            "subSectorId": {
              "type": "string",
              "example": "372cfdc1-2c72-4b6d-890e-319c3b0698ad",
              "description": "Sub Sector ID"
            }
          },
          "required": [
            "tagName",
            "subSectorId"
          ]
        },
        "CreateAttendanceSessionDto": {
          "type": "object",
          "properties": {
            "meetingId": {
              "type": "string",
              "description": "Meeting Id"
            },
            "latitude": {
              "type": "number",
              "example": 12.9715987
            },
            "longitude": {
              "type": "number",
              "example": 77.594566
            },
            "allowedRadius": {
              "type": "number",
              "example": 100,
              "default": 100
            }
          },
          "required": [
            "meetingId",
            "latitude",
            "longitude"
          ]
        },
        "ScanQrDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "description": "user id  ID",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            },
            "attendanceSessionId": {
              "type": "string",
              "description": "Attendance session ID",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            },
            "qrToken": {
              "type": "string",
              "description": "QR token generated for the attendance session",
              "example": "qr_8f4d2a9c7b6e5f1a"
            },
            "latitude": {
              "type": "number",
              "description": "User latitude",
              "example": 12.9715987
            },
            "longitude": {
              "type": "number",
              "description": "User longitude",
              "example": 77.5945627
            }
          },
          "required": [
            "userId",
            "attendanceSessionId",
            "qrToken",
            "latitude",
            "longitude"
          ]
        },
        "ManualAttendanceDto": {
          "type": "object",
          "properties": {
            "meetingId": {
              "type": "string",
              "description": "Meeting ID",
              "example": "e0928de1-051b-4a05-a904-14780407707e",
              "format": "uuid"
            },
            "userId": {
              "type": "string",
              "description": "User ID whose attendance is being marked",
              "example": "733db3d4-588a-43f4-b879-a4077eeee02c",
              "format": "uuid"
            },
            "status": {
              "type": "string",
              "description": "Attendance status",
              "enum": [
                "Present",
                "Absent",
                "Late",
                "Rejected"
              ],
              "example": "Present"
            },
            "attendanceType": {
              "type": "string",
              "description": "Attendance marking type",
              "enum": [
                "QR",
                "Manual",
                "Chairman",
                "Admin",
                "Guest"
              ],
              "example": "Manual"
            },
            "remarks": {
              "type": "string",
              "description": "Reason or remarks for manual attendance",
              "example": "Member arrived late due to traffic."
            },
            "markedBy": {
              "type": "string",
              "description": "Chairman/Admin User ID who marked attendance",
              "example": "efb8608a-6e2a-4cd8-8a3c-1385cf7190a2",
              "format": "uuid"
            }
          },
          "required": [
            "meetingId",
            "userId",
            "status",
            "attendanceType",
            "markedBy"
          ]
        },
        "CloseAttendanceSessionDto": {
          "type": "object",
          "properties": {
            "attendanceSessionId": {
              "type": "string",
              "example": "77a372ea-7fb7-455c-afe7-10893bb59f14"
            }
          },
          "required": [
            "attendanceSessionId"
          ]
        },
        "CreateMembershipApplicationDto": {
          "type": "object",
          "properties": {
            "guestId": {
              "type": "string",
              "description": "Guest ID",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            },
            "businessCategory": {
              "type": "string",
              "description": "Business Category",
              "example": "IT Services"
            },
            "businessSubCategory": {
              "type": "string",
              "description": "Business Sub Category",
              "example": "Software Development"
            },
            "businessTag": {
              "type": "string",
              "description": "Business Tag",
              "example": "Angular, NestJS, Web Development"
            },
            "remarks": {
              "type": "string",
              "description": "Chairman/Admin Remarks",
              "example": "Interested in joining the chapter."
            }
          },
          "required": [
            "guestId",
            "businessCategory"
          ]
        },
        "ReviewMembershipApplicationDto": {
          "type": "object",
          "properties": {
            "applicationId": {
              "type": "string",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            },
            "status": {
              "type": "string",
              "enum": [
                "Pending",
                "Approved",
                "Hold",
                "Rejected"
              ],
              "example": "Approved"
            },
            "remarks": {
              "type": "string",
              "example": "Application approved successfully."
            },
            "reviewedBy": {
              "type": "string",
              "example": "7a9b42d7-6845-48b6-9a11-222222222222"
            }
          },
          "required": [
            "applicationId",
            "status",
            "reviewedBy"
          ]
        },
        "UpdateScoringWeightDto": {
          "type": "object",
          "properties": {
            "action": {
              "type": "string",
              "example": "LEAD_GIVEN",
              "enum": [
                "LEAD_GIVEN",
                "GRATITUDE_SLIP",
                "FACE_TO_FACE",
                "GUEST_BROUGHT",
                "GUEST_JOINED",
                "MEETING_PRESENT",
                "MEETING_ABSENT"
              ]
            },
            "points": {
              "type": "number",
              "example": 10
            }
          },
          "required": [
            "action",
            "points"
          ]
        },
        "UpdateScoreBandDto": {
          "type": "object",
          "properties": {
            "bandName": {
              "type": "string",
              "example": "Green"
            },
            "minScore": {
              "type": "number",
              "example": 70
            },
            "maxScore": {
              "type": "number",
              "example": 999999
            },
            "colorCode": {
              "type": "string",
              "example": "#22C55E"
            }
          },
          "required": [
            "bandName",
            "minScore",
            "maxScore",
            "colorCode"
          ]
        },
        "UpdateScoringSettingsDto": {
          "type": "object",
          "properties": {
            "weights": {
              "example": [
                {
                  "action": "LEAD_GIVEN",
                  "points": 10
                },
                {
                  "action": "GRATITUDE_SLIP",
                  "points": 15
                },
                {
                  "action": "FACE_TO_FACE",
                  "points": 5
                },
                {
                  "action": "GUEST_BROUGHT",
                  "points": 8
                },
                {
                  "action": "GUEST_JOINED",
                  "points": 20
                },
                {
                  "action": "MEETING_PRESENT",
                  "points": 4
                },
                {
                  "action": "MEETING_ABSENT",
                  "points": -10
                }
              ],
              "type": "array",
              "items": {
                "$ref": "#/components/schemas/UpdateScoringWeightDto"
              }
            },
            "bands": {
              "example": [
                {
                  "bandName": "Green",
                  "minScore": 70,
                  "maxScore": 999999,
                  "colorCode": "#22C55E"
                },
                {
                  "bandName": "Amber",
                  "minScore": 40,
                  "maxScore": 69,
                  "colorCode": "#F59E0B"
                },
                {
                  "bandName": "Red",
                  "minScore": -999999,
                  "maxScore": 39,
                  "colorCode": "#EF4444"
                }
              ],
              "type": "array",
              "items": {
                "$ref": "#/components/schemas/UpdateScoreBandDto"
              }
            }
          },
          "required": [
            "weights",
            "bands"
          ]
        },
        "PlanFeatureDto": {
          "type": "object",
          "properties": {
            "featureName": {
              "type": "string",
              "example": "Business Directory"
            }
          },
          "required": [
            "featureName"
          ]
        },
        "CreateMembershipPlanDto": {
          "type": "object",
          "properties": {
            "planName": {
              "type": "string",
              "example": "Prime Plan"
            },
            "membershipType": {
              "type": "string",
              "enum": [
                "BASIC",
                "PRIME",
                "PATRON"
              ],
              "example": "PRIME"
            },
            "price": {
              "type": "number",
              "example": 25000
            },
            "durationDays": {
              "type": "number",
              "example": 365
            },
            "badge": {
              "type": "string",
              "example": "Most Popular"
            },
            "isPopular": {
              "type": "boolean",
              "example": true
            },
            "features": {
              "type": "array",
              "items": {
                "$ref": "#/components/schemas/PlanFeatureDto"
              }
            }
          },
          "required": [
            "planName",
            "membershipType",
            "price",
            "durationDays",
            "isPopular",
            "features"
          ]
        },
        "UpdateMembershipPlanDto": {
          "type": "object",
          "properties": {
            "planName": {
              "type": "string",
              "description": "Membership plan name",
              "example": "Prime Membership"
            },
            "membershipType": {
              "type": "string",
              "description": "Type of membership plan",
              "enum": [
                "BASIC",
                "PRIME",
                "PATRON"
              ],
              "example": "PRIME"
            },
            "price": {
              "type": "number",
              "description": "Membership plan price",
              "example": 4999
            },
            "durationDays": {
              "type": "number",
              "description": "Membership duration in days",
              "example": 365
            },
            "badge": {
              "type": "string",
              "description": "Badge displayed for the membership plan",
              "example": "Premium"
            },
            "isPopular": {
              "type": "boolean",
              "description": "Whether this plan should be displayed as popular",
              "example": true
            },
            "isActive": {
              "type": "boolean",
              "description": "Whether the membership plan is active",
              "example": true
            },
            "features": {
              "description": "Features included in the membership plan",
              "example": [
                {
                  "featureName": "Unlimited Leads"
                },
                {
                  "featureName": "Priority Support"
                },
                {
                  "featureName": "Business Analytics"
                },
                {
                  "featureName": "Premium Badge"
                }
              ],
              "type": "array",
              "items": {
                "type": "object"
              }
            }
          }
        },
        "UpdateUserMembershipDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8f67d2b2-45d7-4b8c-a56b-9c6d8f8b1a23"
            },
            "isBasic": {
              "type": "boolean",
              "example": false
            },
            "isPrime": {
              "type": "boolean",
              "example": true
            },
            "isPatron": {
              "type": "boolean",
              "example": false
            }
          },
          "required": [
            "userId",
            "isBasic",
            "isPrime",
            "isPatron"
          ]
        },
        "CreateMembershipOrderDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8d1c3b84-5f3a-4d97-9d0d-2d7f8c5a6b11",
              "description": "User ID"
            },
            "planId": {
              "type": "string",
              "example": "b5b6d30f-2c59-47b9-a45b-ff84c8e72abc",
              "description": "Membership Plan ID"
            }
          },
          "required": [
            "userId",
            "planId"
          ]
        },
        "VerifyMembershipPaymentDto": {
          "type": "object",
          "properties": {
            "paymentId": {
              "type": "string"
            },
            "razorpayOrderId": {
              "type": "string"
            },
            "razorpayPaymentId": {
              "type": "string"
            },
            "razorpaySignature": {
              "type": "string"
            }
          },
          "required": [
            "paymentId",
            "razorpayOrderId",
            "razorpayPaymentId",
            "razorpaySignature"
          ]
        },
        "CreateNewsDto": {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "example": "Government launches new MSME policy"
            },
            "summary": {
              "type": "string",
              "example": "The Government has announced several benefits for MSMEs."
            },
            "body": {
              "type": "string",
              "example": "Complete article content goes here..."
            },
            "category": {
              "type": "string",
              "example": "Business"
            },
            "source": {
              "type": "string",
              "example": "Economic Times"
            },
            "imageUrl": {
              "type": "string",
              "example": "https://example.com/image.jpg"
            },
            "sourceUrl": {
              "type": "string",
              "example": "https://economictimes.indiatimes.com/article"
            },
            "publishedAt": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30T10:30:00.000Z"
            },
            "isFeatured": {
              "type": "boolean",
              "example": false
            }
          },
          "required": [
            "title",
            "summary",
            "category",
            "source",
            "publishedAt"
          ]
        },
        "UpdateNewsDto": {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "example": "Government launches new MSME policy"
            },
            "summary": {
              "type": "string",
              "example": "The Government has announced several benefits for MSMEs."
            },
            "body": {
              "type": "string",
              "example": "Complete article content goes here..."
            },
            "category": {
              "type": "string",
              "example": "Business"
            },
            "source": {
              "type": "string",
              "example": "Economic Times"
            },
            "imageUrl": {
              "type": "string",
              "example": "https://example.com/image.jpg"
            },
            "sourceUrl": {
              "type": "string",
              "example": "https://economictimes.indiatimes.com/article"
            },
            "publishedAt": {
              "format": "date-time",
              "type": "string",
              "example": "2026-07-30T10:30:00.000Z"
            },
            "isFeatured": {
              "type": "boolean",
              "example": false
            }
          }
        },
        "CreateJobDto": {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "example": "Business Development Executive",
              "description": "Job title"
            },
            "companyName": {
              "type": "string",
              "example": "ABC Technologies Pvt. Ltd.",
              "description": "Company name"
            },
            "category": {
              "type": "string",
              "example": "Sales",
              "description": "Job category"
            },
            "location": {
              "type": "string",
              "example": "Kharadi IT Park",
              "description": "Job location"
            },
            "city": {
              "type": "string",
              "example": "Pune",
              "description": "City"
            },
            "ward": {
              "type": "string",
              "example": "Ward 12",
              "description": "Ward name"
            },
            "salaryRange": {
              "type": "string",
              "example": "₹3,00,000 - ₹5,00,000 Per Year",
              "description": "Salary range"
            },
            "jobType": {
              "type": "string",
              "enum": [
                "FULL_TIME",
                "PART_TIME",
                "CONTRACT",
                "INTERNSHIP",
                "FREELANCE"
              ],
              "example": "FULL_TIME",
              "description": "Employment type"
            },
            "openings": {
              "type": "number",
              "example": 5,
              "description": "Number of openings"
            },
            "experience": {
              "type": "string",
              "example": "2-4 Years",
              "description": "Required experience"
            },
            "requirements": {
              "type": "string",
              "example": "Bachelor degree, Excellent communication skills, Good knowledge of MS Office and CRM software.",
              "description": "Job requirements"
            }
          },
          "required": [
            "title",
            "companyName",
            "category",
            "location",
            "city",
            "jobType",
            "openings",
            "experience",
            "requirements"
          ]
        },
        "UpdateJobDto": {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "example": "Business Development Executive",
              "description": "Job title"
            },
            "companyName": {
              "type": "string",
              "example": "ABC Technologies Pvt. Ltd.",
              "description": "Company name"
            },
            "category": {
              "type": "string",
              "example": "Sales",
              "description": "Job category"
            },
            "location": {
              "type": "string",
              "example": "Kharadi IT Park",
              "description": "Job location"
            },
            "city": {
              "type": "string",
              "example": "Pune",
              "description": "City"
            },
            "ward": {
              "type": "string",
              "example": "Ward 12",
              "description": "Ward name"
            },
            "salaryRange": {
              "type": "string",
              "example": "₹3,00,000 - ₹5,00,000 Per Year",
              "description": "Salary range"
            },
            "jobType": {
              "type": "string",
              "enum": [
                "FULL_TIME",
                "PART_TIME",
                "CONTRACT",
                "INTERNSHIP",
                "FREELANCE"
              ],
              "example": "FULL_TIME",
              "description": "Employment type"
            },
            "openings": {
              "type": "number",
              "example": 5,
              "description": "Number of openings"
            },
            "experience": {
              "type": "string",
              "example": "2-4 Years",
              "description": "Required experience"
            },
            "requirements": {
              "type": "string",
              "example": "Bachelor degree, Excellent communication skills, Good knowledge of MS Office and CRM software.",
              "description": "Job requirements"
            },
            "status": {
              "type": "string",
              "enum": [
                "OPEN",
                "CLOSED"
              ],
              "example": "OPEN"
            }
          }
        },
        "ApplyJobDto": {
          "type": "object",
          "properties": {
            "jobId": {
              "type": "string",
              "example": "d7b7f4b5-3d91-4d7d-a18c-62f6d4ef1234",
              "description": "Job Id"
            },
            "fullName": {
              "type": "string",
              "example": "Suraj Sukale",
              "description": "Applicant Full Name"
            },
            "email": {
              "type": "string",
              "example": "suraj@gmail.com",
              "description": "Applicant Email"
            },
            "mobile": {
              "type": "string",
              "example": "9876543210",
              "description": "Mobile Number"
            },
            "currentCity": {
              "type": "string",
              "example": "Pune",
              "description": "Current City"
            },
            "qualification": {
              "type": "string",
              "example": "BCA",
              "description": "Highest Qualification"
            },
            "experience": {
              "type": "string",
              "example": "2.5 Years",
              "description": "Total Experience"
            },
            "currentCompany": {
              "type": "string",
              "example": "Senwell Group Pvt. Ltd.",
              "description": "Current Company"
            },
            "currentSalary": {
              "type": "string",
              "example": "₹5 LPA",
              "description": "Current Salary"
            },
            "expectedSalary": {
              "type": "string",
              "example": "₹8 LPA",
              "description": "Expected Salary"
            },
            "resumeUrl": {
              "type": "string",
              "example": "https://your-domain.com/uploads/resume/suraj_resume.pdf",
              "description": "Uploaded Resume URL"
            },
            "coverLetter": {
              "type": "string",
              "example": "I am excited to apply for this opportunity and believe my skills match your requirements.",
              "description": "Cover Letter"
            }
          },
          "required": [
            "jobId",
            "fullName",
            "email",
            "mobile",
            "currentCity",
            "qualification",
            "experience",
            "resumeUrl"
          ]
        },
        "CreateSubBusinessVerticalDto": {
          "type": "object",
          "properties": {
            "subVerticalName": {
              "type": "string",
              "example": "Property Documentation",
              "description": "Name of the sub business vertical.",
              "maxLength": 150
            },
            "description": {
              "type": "string",
              "example": "Property documentation and paperwork related services.",
              "description": "Description of the sub business vertical."
            },
            "verticalId": {
              "type": "string",
              "example": "13e3fe90-702c-4502-b387-b84c11c06c96",
              "description": "ID of the parent/main business vertical."
            },
            "isActive": {
              "type": "boolean",
              "example": true,
              "default": true,
              "description": "Whether the sub business vertical is active."
            },
            "displayOrder": {
              "type": "number",
              "example": 1,
              "default": 0,
              "description": "Display order of the sub business vertical."
            }
          },
          "required": [
            "subVerticalName",
            "verticalId"
          ]
        },
        "CreateChannelPartnerFormDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "3e14b4b8-c4d4-42ab-8e2d-0ab8e5d1111",
              "description": "Ward Chairman User ID"
            },
            "title": {
              "type": "string",
              "example": "Channel Partner Registration"
            },
            "description": {
              "type": "string",
              "example": "Registration form for new business."
            },
            "channelPartnerId": {
              "type": "string",
              "example": "95d4ac6b-c21a-4ca3-bd20-f94285064584",
              "description": "Channel Partner User ID"
            },
            "businessName": {
              "type": "string",
              "example": "ABC Enterprises",
              "description": "Business Name"
            },
            "formSchema": {
              "description": "Dynamic form schema",
              "type": "array",
              "items": {
                "type": "object"
              }
            },
            "isActive": {
              "type": "boolean",
              "default": true
            }
          },
          "required": [
            "userId",
            "title",
            "channelPartnerId",
            "businessName",
            "formSchema"
          ]
        },
        "UpdateSubmissionStatusDto": {
          "type": "object",
          "properties": {
            "submissionId": {
              "type": "string",
              "example": "9d7d4b5c-8f21-4db8-b5d6-7f8e9c123456"
            },
            "chairmanUserId": {
              "type": "string",
              "example": "3e14b4b8-c4d4-42ab-8e2d-0ab8e5d1111"
            },
            "status": {
              "type": "string",
              "example": "Approved"
            }
          },
          "required": [
            "submissionId",
            "chairmanUserId",
            "status"
          ]
        },
        "UpdateSurveyStatusDto": {
          "type": "object",
          "properties": {
            "wardChairmanId": {
              "type": "string",
              "example": "f9a6257c-7cbe-4c1c-a25a-8403ee801110",
              "description": "Ward Chairman User ID"
            },
            "status": {
              "type": "string",
              "enum": [
                "VERIFIED",
                "REJECTED"
              ],
              "example": "VERIFIED"
            },
            "rejectionReason": {
              "type": "string",
              "example": "House image is not clear.",
              "description": "Required when survey is rejected."
            }
          },
          "required": [
            "wardChairmanId",
            "status"
          ]
        },
        "CreateRouteDto": {
          "type": "object",
          "properties": {
            "wardChairmanId": {
              "type": "string",
              "example": "3e14b4b8-c4d4-42ab-8e2d-0ab8e5d1111",
              "description": "Ward Chairman User ID"
            },
            "channelPartnerId": {
              "type": "string",
              "example": "7fd4a155-6934-4e8a-9b65-d3f1e8c7f123",
              "description": "Channel Partner User ID"
            },
            "routeName": {
              "type": "string",
              "example": "Ward 48 Morning Survey Route",
              "description": "Route Name"
            },
            "routePath": {
              "type": "object",
              "description": "Google Maps GeoJSON Route",
              "example": {
                "type": "LineString",
                "coordinates": [
                  [
                    77.5946,
                    12.9716
                  ],
                  [
                    77.5951,
                    12.9721
                  ],
                  [
                    77.5968,
                    12.9732
                  ],
                  [
                    77.5975,
                    12.974
                  ]
                ]
              }
            },
            "plannedDistance": {
              "type": "number",
              "example": 5400,
              "description": "Planned Distance in meters"
            },
            "estimatedDuration": {
              "type": "number",
              "example": 90,
              "description": "Estimated Duration in minutes"
            }
          },
          "required": [
            "wardChairmanId",
            "channelPartnerId",
            "routeName",
            "routePath",
            "plannedDistance",
            "estimatedDuration"
          ]
        },
        "UpdateRouteDto": {
          "type": "object",
          "properties": {
            "routeId": {
              "type": "string",
              "example": "5a4d9b6c-4a88-4c8b-bdf7-9b2c1e7f1111"
            },
            "wardChairmanId": {
              "type": "string",
              "example": "3e14b4b8-c4d4-42ab-8e2d-0ab8e5d1111"
            },
            "routeName": {
              "type": "string",
              "example": "Ward 48 Evening Survey"
            },
            "routePath": {
              "type": "object",
              "example": {
                "type": "LineString",
                "coordinates": [
                  [
                    77.5946,
                    12.9716
                  ],
                  [
                    77.5951,
                    12.9721
                  ],
                  [
                    77.5968,
                    12.9732
                  ]
                ]
              }
            },
            "plannedDistance": {
              "type": "number",
              "example": 6200
            },
            "estimatedDuration": {
              "type": "number",
              "example": 100
            }
          }
        },
        "UpdateRouteLocationDto": {
          "type": "object",
          "properties": {
            "routeId": {
              "type": "string",
              "example": "b5f96d83-18d7-4d0d-8d7b-9a8b3f1f2d21",
              "description": "Channel Partner Route ID"
            },
            "channelPartnerId": {
              "type": "string",
              "example": "7fd4a155-6934-4e8a-9b65-d3f1e8c7f123",
              "description": "Channel Partner User ID"
            },
            "latitude": {
              "type": "number",
              "example": 12.9716,
              "description": "Current latitude of Channel Partner"
            },
            "longitude": {
              "type": "number",
              "example": 77.5946,
              "description": "Current longitude of Channel Partner"
            },
            "accuracy": {
              "type": "number",
              "example": 5,
              "description": "GPS accuracy in meters"
            },
            "speed": {
              "type": "number",
              "example": 12.5,
              "description": "Current speed in km/h"
            },
            "battery": {
              "type": "number",
              "example": 85,
              "description": "Mobile battery percentage"
            }
          },
          "required": [
            "routeId",
            "channelPartnerId",
            "latitude",
            "longitude"
          ]
        },
        "CreateChannelPartnerApplicationDto": {
          "type": "object",
          "properties": {
            "fullName": {
              "type": "string",
              "example": "Bhoomi Patil"
            },
            "dateOfBirth": {
              "type": "string",
              "example": "1995-05-20",
              "description": "Applicant must be at least 21 years old."
            },
            "mobileNumber": {
              "type": "string",
              "example": "9876543210"
            },
            "residenceLocality": {
              "type": "string",
              "example": "Kharadi, Pune"
            },
            "isExistingMember": {
              "type": "boolean",
              "example": true
            },
            "memberId": {
              "type": "string",
              "example": "UDYM001",
              "description": "Existing Udyami / FCMSL member ID. This must exist in users.memberId."
            },
            "subVerticalId": {
              "type": "string",
              "example": "4918a643-34a1-41ab-87a6-e3fc0eda02c5",
              "description": "Sub Business Vertical ID selected by the Channel Partner."
            },
            "selectedServices": {
              "example": [
                "Legal Opinion",
                "Asset Management"
              ],
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "fdAmount": {
              "type": "number",
              "example": 25000,
              "description": "Fixed Deposit amount applicable for the selected sub business vertical.",
              "minimum": 0
            },
            "appliedTerritory": {
              "type": "string",
              "example": "Ward 14"
            },
            "wardId": {
              "type": "string",
              "example": "b2f6a2b1-5a1a-4c2c-9c5d-123456789abc"
            },
            "businessOfficeAddress": {
              "type": "string",
              "example": "Shop No. 12, Main Road, Kharadi, Pune"
            },
            "ownership": {
              "type": "string",
              "enum": [
                "OWNED",
                "RENTED",
                "LEASED",
                "SHARED",
                "OTHER"
              ],
              "example": "OWNED"
            },
            "nearestLandmark": {
              "type": "string",
              "example": "Near EON IT Park"
            },
            "hasDedicatedWalkInSpace": {
              "type": "boolean",
              "example": true
            },
            "hasInternetAndDigitalCapability": {
              "type": "boolean",
              "example": true
            },
            "hasRelevantExperience": {
              "type": "boolean",
              "example": true
            },
            "premisesDeclarationAccepted": {
              "type": "boolean",
              "example": true,
              "description": "Applicant must accept that premises are suitable for onboarding."
            },
            "experienceDescription": {
              "type": "string",
              "example": "I have 4 years of experience in property documentation and financial services."
            },
            "yearsOfExperience": {
              "type": "number",
              "example": 4,
              "minimum": 0
            },
            "expectedSubscribersMonthOne": {
              "type": "number",
              "example": 25,
              "minimum": 0
            },
            "willEmploySupportStaff": {
              "type": "boolean",
              "example": true
            },
            "dashboardComfort": {
              "type": "string",
              "enum": [
                "NO",
                "WITH_TRAINING",
                "YES"
              ],
              "example": "WITH_TRAINING"
            },
            "trainingAvailability": {
              "type": "string",
              "enum": [
                "WEEKDAYS",
                "WEEKENDS",
                "BOTH"
              ],
              "example": "WEEKDAYS"
            },
            "kycResponsibilityAccepted": {
              "type": "boolean",
              "example": true
            },
            "identityVerificationConsent": {
              "type": "boolean",
              "example": true,
              "description": "Consent for Aadhaar / PAN / bank penny-drop verification."
            },
            "backgroundVerificationConsent": {
              "type": "boolean",
              "example": true
            },
            "trainingRequirementAccepted": {
              "type": "boolean",
              "example": true
            },
            "agreementAccepted": {
              "type": "boolean",
              "example": true,
              "description": "Must be true to submit the application."
            },
            "agreementVersion": {
              "type": "string",
              "example": "CP_AGREEMENT_V1.0"
            }
          },
          "required": [
            "fullName",
            "dateOfBirth",
            "mobileNumber",
            "residenceLocality",
            "isExistingMember",
            "memberId",
            "subVerticalId",
            "selectedServices",
            "fdAmount",
            "appliedTerritory",
            "businessOfficeAddress",
            "ownership",
            "hasDedicatedWalkInSpace",
            "hasInternetAndDigitalCapability",
            "hasRelevantExperience",
            "premisesDeclarationAccepted",
            "willEmploySupportStaff",
            "dashboardComfort",
            "trainingAvailability",
            "kycResponsibilityAccepted",
            "identityVerificationConsent",
            "backgroundVerificationConsent",
            "trainingRequirementAccepted",
            "agreementAccepted"
          ]
        },
        "ChannelPartnerApplicationStatus": {
          "type": "string",
          "enum": [
            "DRAFT",
            "SUBMITTED",
            "UNDER_REVIEW",
            "APPROVED",
            "REJECTED",
            "TRAINING_PENDING",
            "TRAINING_COMPLETED",
            "ACTIVE",
            "WITHDRAWN"
          ],
          "description": "Select the new status for the Channel Partner application."
        },
        "UpdateChannelPartnerApplicationStatusDto": {
          "type": "object",
          "properties": {
            "status": {
              "example": "UNDER_REVIEW",
              "description": "Select the new status for the Channel Partner application.",
              "allOf": [
                {
                  "$ref": "#/components/schemas/ChannelPartnerApplicationStatus"
                }
              ]
            },
            "userId": {
              "type": "string",
              "example": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
              "description": "User ID of the Ward Chairman who is updating the application status."
            },
            "rejectionReason": {
              "type": "string",
              "example": "Application rejected because the required documents were incomplete.",
              "description": "Required only when the selected status is REJECTED.",
              "maxLength": 1000
            }
          },
          "required": [
            "status",
            "userId"
          ]
        },
        "ScheduleInterviewDto": {
          "type": "object",
          "properties": {
            "applicationId": {
              "type": "string",
              "description": "Channel Partner application ID."
            },
            "scheduledByUserId": {
              "type": "string",
              "description": "User ID of the Ward Chairman scheduling the interview."
            },
            "scheduledAt": {
              "type": "string",
              "example": "2026-08-15T10:30:00.000Z",
              "description": "Scheduled interview date and time."
            },
            "durationMinutes": {
              "type": "number",
              "example": 30,
              "description": "Interview duration in minutes."
            },
            "interviewMode": {
              "type": "string",
              "enum": [
                "IN_PERSON",
                "ONLINE",
                "PHONE"
              ],
              "example": "IN_PERSON",
              "description": "Mode of the interview."
            },
            "locationName": {
              "type": "string",
              "example": "Udyami Office, Bengaluru",
              "description": "Name of the interview location."
            },
            "locationAddress": {
              "type": "string",
              "example": "1st Floor, Udyami Building, MG Road, Bengaluru.",
              "description": "Complete interview location address."
            },
            "latitude": {
              "type": "number",
              "example": 12.9716,
              "description": "Latitude of the physical interview location."
            },
            "longitude": {
              "type": "number",
              "example": 77.5946,
              "description": "Longitude of the physical interview location."
            },
            "meetingLink": {
              "type": "string",
              "example": "https://meet.google.com/example",
              "description": "Meeting link for online interview."
            },
            "interviewInstructions": {
              "type": "string",
              "example": "Please bring all required documents.",
              "description": "Instructions for the applicant."
            }
          },
          "required": [
            "applicationId",
            "scheduledByUserId",
            "scheduledAt",
            "interviewMode"
          ]
        },
        "UpdateInterviewStatusDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "description": "User ID changing the interview status."
            },
            "status": {
              "type": "string",
              "enum": [
                "SCHEDULED",
                "RESCHEDULED",
                "COMPLETED",
                "CANCELLED",
                "NO_SHOW"
              ],
              "example": "CANCELLED"
            },
            "cancellationReason": {
              "type": "string",
              "description": "Reason for cancellation."
            },
            "rescheduleReason": {
              "type": "string",
              "description": "Reason for rescheduling."
            },
            "interviewNotes": {
              "type": "string",
              "description": "Interview notes."
            }
          },
          "required": [
            "userId",
            "status"
          ]
        },
        "UpdatePostDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8b7d6e5f-1234-4567-8901-abcdef123456"
            },
            "content": {
              "type": "string",
              "example": "Updated post content.",
              "maxLength": 5000
            }
          },
          "required": [
            "userId",
            "content"
          ]
        },
        "PostLikeDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8b7d6e5f-1234-4567-8901-abcdef123456",
              "description": "User ID who is liking or unliking the post."
            }
          },
          "required": [
            "userId"
          ]
        },
        "CreatePostCommentDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8b7d6e5f-1234-4567-8901-abcdef123456",
              "description": "User ID who is commenting on the post."
            },
            "content": {
              "type": "string",
              "example": "Great post! Thanks for sharing.",
              "description": "Comment text.",
              "maxLength": 2000
            },
            "imageUrl": {
              "type": "object",
              "example": null,
              "description": "Optional image URL/base64 image attached to the comment."
            }
          },
          "required": [
            "userId",
            "content"
          ]
        },
        "CreateCommentReactionDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8b7d6e5f-1234-4567-8901-abcdef123456",
              "description": "User ID who is reacting to the comment."
            },
            "reactionType": {
              "type": "string",
              "enum": [
                "love",
                "clap",
                "fire",
                "clap_hands",
                "heart_eyes",
                "cry",
                "wow",
                "laugh"
              ],
              "example": "love",
              "description": "Reaction type."
            }
          },
          "required": [
            "userId",
            "reactionType"
          ]
        },
        "SharePostDto": {
          "type": "object",
          "properties": {
            "userId": {
              "type": "string",
              "example": "8b7d6e5f-1234-4567-8901-abcdef123456",
              "description": "User ID who is sharing the post."
            }
          },
          "required": [
            "userId"
          ]
        }
      }
    }
  },
  "customOptions": {
    "persistAuthorization": true,
    "docExpansion": "list",
    "displayRequestDuration": true,
    "filter": true
  }
};
  url = options.swaggerUrl || url
  let urls = options.swaggerUrls
  let customOptions = options.customOptions
  let spec1 = options.swaggerDoc
  let swaggerOptions = {
    spec: spec1,
    url: url,
    urls: urls,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  }
  for (let attrname in customOptions) {
    swaggerOptions[attrname] = customOptions[attrname];
  }
  let ui = SwaggerUIBundle(swaggerOptions)

  if (customOptions.initOAuth) {
    ui.initOAuth(customOptions.initOAuth)
  }

  if (customOptions.authAction) {
    ui.authActions.authorize(customOptions.authAction)
  }
  
  window.ui = ui
}
