request = require 'request'
xml2js = require 'xml2js'

makeUrl = (query, max_results=100, sort_by='lastUpdatedDate') ->
    "http://export.arxiv.org/api/query?sortBy=#{sort_by}&max_results=#{max_results}&search_query=#{query}"

key_map =
    author: 'au'
    title: 'ti'
    category: 'cat'

coerceQueryKey = (key) ->
    key_map[key] or key

coerceQueryValue = (key, value) ->
    if key == 'au'
        if matched = value.match /^(\w+).* (\w+)$/
            matched[2] + '_' + matched[1][0]
        else
            value
    else
        value

coerceQuery = (query) ->
    querys = []
    for k, v of query
        k = coerceQueryKey k
        v = coerceQueryValue k, v
        querys.push [k, v].join(':')
    querys.join('+AND+')

coerceEntry = (entry) -> {
    id: entry.id[0]
    updated: new Date entry.updated[0]
    published: new Date entry.published[0]
    title: entry.title[0].trim().replace(/\s+/g, ' ')
    summary: entry.summary[0].trim().replace(/\s+/g, ' ')
    links: entry.link.map (link) -> {href: link['$']['href'], title: link['$']['title']}
    authors: entry.author.map (author) -> {name: author['name'][0]}
    categories: entry.category.map (category) -> category['$']['term']
}

search = (query, cb) ->
    request.get makeUrl(coerceQuery(query)), (err, resp, data) ->
        xml2js.parseString data, (err, parsed) ->
            cb err, parsed?.feed?.entry?.map coerceEntry

module.exports = {
    search
}

