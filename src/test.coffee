arxiv = require '.'

test_search = {au: 'Xu_L', cat: 'cs*'}
test_search = {title: 'RNN', author: 'William Chan'}

arxiv.search test_search, (err, results) ->
    console.log results.map((result) ->
        result.title + '\n - ' + result.authors.map((a) -> a.name).join(', ')
    ).join('\n\n')

