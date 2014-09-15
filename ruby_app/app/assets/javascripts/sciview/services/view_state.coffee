app = angular.module('sv.ui.services')

app.factory('ViewState', ['$resource',
  ($resource) -> return $resource(
    '/api/v1/view_states/:id.json',
    { id: '@id' }, {
      index:  { method: 'GET', isArray: true }
      update: { method: 'PUT' }
      delete: { method: 'DELETE' }
    }
  )
])
