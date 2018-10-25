WikiTools = angular.module('WikiTools', [])

WikiToolsService = ($log, $http, $httpParamSerializer, $q, $sce) ->
  wdApiParams = $httpParamSerializer
    format: 'json'
    formatversion: 2

  @createApi = (param1, param2) ->
    [param1, param2] = ['base', param1] if not param2
    "https://#{param1}.#{param2}.co/api.php?#{wdApiParams}"

  @url = @createApi 'transformap'
  @wikibase = $sce.trustAsResourceUrl(@url)

  @get = (api, params) ->
    $http.jsonp(api, {
      params: params,
      jsonpCallbackParam: 'callback'
    })

  @searchEntities = (type, query, language) =>
    params =
      action: 'wbsearchentities'
      search: query
      uselang: language,
      language: language
      type: type
      continue: 0

    success = (response) => response.data.search
    error = (response) -> $log.error 'Request failed'; $q.reject 'Request failed'
    @get(@wikibase, params).then(success, error)

  @getEntity = (what, language) =>
    params =
      action: 'wbsearchentities'
      search: what
      uselang: language
      language: language
      type: if what.startsWith('Q') then 'item' else 'property'
      limit: 1

    success = (response) =>
      if not response.data.search
        id: what, label: what, lang: language
      else
        out = response.data.search[0]
        out.lang = language
        out
    error = (response) -> $log.error 'Request failed'; $q.reject 'Request failed'
    @get(@wikibase, params).then(success, error)

  @wdqs = (query) ->
    $http.get('https://query.base.transformap.co/bigdata/namespace/transformap/sparql', params: query: query)

  return

WikiToolsService.$inject = ['$log', '$http', '$httpParamSerializer', '$q', '$sce']

WikiTools.service 'WikiToolsService', WikiToolsService
