module.exports = {
  port : 8080
  outPath : "/home/ray/tmp/blog_out"
  plugins:
    marked:
      pedantic: false
      gfm: true
      sanitize: false
      highlight: null

  templateData : 
    site: 
      url: "http://oopschen.github.io",
      title: "Mr.C Blog",
      description: "Focued on Tech"
      include3rd : true
      donateURL: "https://me.alipay.com/sangeshitou"

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

  collections:
    pages: ->
      @getCollection("html").findAllLive({layout: "post"}, [{date: -1}])

    indexPages: ->
      doc = @getCollection("html").findAllLive({layout: "post"}, [{date: -1}])
      if doc
        if 7 < doc.length
          doc[0..7]
        else
          doc
        
  environments:  
    development:  
      templateData : 
        site : 
          url: "http://127.0.0.1:8080"
          include3rd : false
}
