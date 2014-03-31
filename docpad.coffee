module.exports = {
  port : 8080
  outPath : "/home/ray/tmp/blog_out"
  plugins:
    marked:
      pedantic: false
      gfm: true
      sanitize: false
      highlight: null
    moment:
      formats: [
        {raw: 'date', format: 'MMMM Do YYYY, HH:mm', formatted: 'formattedDate'}
      ]
    sitemap:
      cachetime: 600000
      changefreq: 'weekly'
      priority: 0.5
      filePath: 'sitemap.xml'
    htmlmin:
      removeComments: true
      removeCommentsFromCDATA: false
      removeCDATASectionsFromCDATA: false
      collapseWhitespace: true
      collapseBooleanAttributes: false
      removeAttributeQuotes: false
      removeRedundantAttributes: false
      useShortDoctype: false
      removeEmptyAttributes: false
      removeOptionalTags: false
      removeEmptyElements: false
    cleancss:
      cleancssOpts:
        keepSpecialComments: '*'
        keepBreaks: false
        benchmark: false
        processImport: true
        noRebase: false
        noAdvanced: false
        debug: false
    uglify:
        compress: {}
        mangle: {}

  templateData : 
    site: 
      title: "Mr.C Blog",
      author: "Mr.C",
      description: "Focued on Tech"
      donateURL: "https://me.alipay.com/sangeshitou"
      rippleaddr: "rMffqNoGBzzdzWTqtdeGto74GypdToywML"
        
    getThisYear: ->  
      @moment(new Date()).format('YYYY') 

    getPreparedTitle: ->
      if @document.title
        "#{@document.title} | #{@site.title}"
      else
        @site.title

    getPreparedDescription: ->
      @document.description or @site.description

    getPreparedTags: (doc) ->
      tags = []
      if doc.tags
        tags = doc.tags
        tags2 = []
        for t in tags
          tags2.push x for x in t.split "，"
        tags = tags2
      tags

    formatArchive: (colls) ->
      page = {}
      if colls
        for p in colls
          y = p.date.getFullYear()

          if y of page
            page[y].push p
          else
            page[y] = [p]
      page["list"] = (y for y of page).sort (a,b) -> b - a
      page

    formatDate: (x)->
      @moment(x).format('MMMM Do YYYY, HH:mm') 

    subArray: (arr, maxlen) ->
      if arr
        if maxlen < arr.length
          arr[0..maxlen-1]
        else
          arr
      else
        arr

    shortenTitle: (title) ->
      if not title
        "none"
      else if 32 < title.length
        (title.substring 0, 32) + "..."
      else
        title
      
    getLatestPosts: ->
      @subArray(@getCollection("pages").toJSON(), 3)

    getCuttedContent: (content) ->            
      i = content.search('<!-- more -->')
      if i >= 0
        content[0..i-1]                
      else
        content

    hasReadMore: (content) ->
        content.search('<!-- more -->') >= 0

  collections:
    pages: ->
      @getCollection("html").findAllLive({layout: "post"}, [{date: -1}])

    indexPages: ->
      @getCollection("html").findAllLive({layout: "post"}, [{date: -1}])
        
  environments:  
    development:  
      enabled: false
      templateData : 
        include3rd : false
        site:
          url: "http://127.0.0.1:8080"

    product:
      enabled: false
      templateData : 
        site:
          url: "http://127.0.0.1:8080"
        include3rd : true

    # for github push
    deploy:
      enabled: true
      templateData : 
        include3rd : true
        site:
          url: "http://oopschen.github.io",
}
