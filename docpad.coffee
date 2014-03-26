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
      url: "http://oopschen.github.io",
      title: "Mr.C Blog",
      description: "Focued on Tech"
      donateURL: "https://me.alipay.com/sangeshitou"
      rippleaddr: "rMffqNoGBzzdzWTqtdeGto74GypdToywML"

    getPreparedTitle: ->
      if @document.title
        "#{@document.title} | #{@site.title}"
      else
        @site.title

    getPreparedDescription: ->
      @document.description or @site.description

    getIndexPages: ->
      @getCollection("indexPages")

    formatArchive: (colls) ->
      page = {}
      if colls
        for p in colls
          y = p.date.getFullYear()

          if y of page
            page[y].push p
          else
            page[y] = [p]
      page

    formatDate: (x)->
      @moment(x).format('MMMM Do YYYY, HH:mm') 

  collections:
    pages: ->
      @getCollection("html").findAllLive({layout: "post"}, [{date: -1}]).on "add", (model) ->
                model.setMetaDefaults({htmlmin: true})

    indexPages: ->
      doc = @getCollection("html").findAllLive({layout: "post"}, [{date: -1}])
      if doc
        if 7 < doc.length
          doc[0..7]
        else
          doc
        
  environments:  
    development:  
      enabled: false
      templateData : 
        url: "http://127.0.0.1:8080"
        include3rd : false

    product:
      enabled: false
      templateData : 
        url: "http://127.0.0.1:8080"
        include3rd : true

    # for github push
    deploy:
      enabled: true
      templateData : 
        include3rd : true
}
