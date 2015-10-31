var _ = require('underscore');

module.exports = {
  port: 8080,
  plugins: {
    ghpages: {
      deployRemote: 'origin',
      deployBranch: 'master'
    },
    marked: {
      pedantic: false,
      gfm: true,
      sanitize: false,
      highlight: null
    },
    moment: {
      formats: [
        {raw: 'date', format: 'MMMM Do YYYY, HH:mm', formatted: 'formattedDate'}
      ]
    },
    sitemap: {
      cachetime: 600000,
      changefreq: 'weekly',
      priority: 0.5,
      filePath: 'sitemap.xml'
    },
    htmlmin: {
      removeComments: true,
      removeCommentsFromCDATA: false,
      removeCDATASectionsFromCDATA: false,
      collapseWhitespace: true,
      collapseBooleanAttributes: false,
      removeAttributeQuotes: false,
      removeRedundantAttributes: false,
      useShortDoctype: false,
      removeEmptyAttributes: false,
      removeOptionalTags: false,
      removeEmptyElements: false
    },
    cleancss: {
      cleancssOpts: {
        keepSpecialComments: '*',
        keepBreaks: false,
        benchmark: false,
        processImport: true,
        noRebase: false,
        noAdvanced: false,
        debug: false
      }
    },
    uglify: {
        compress: {},
        mangle: {}
    }
  },

  templateData : {
    site: {
      title: "Mr.C Blog",
      author: "Mr.C",
      description: "Focued on Tech",
      donateURL: "https://me.alipay.com/sangeshitou",
      rippleaddr: "rMffqNoGBzzdzWTqtdeGto74GypdToywML"
    },
        
    getThisYear: function () {
      return this.moment(new Date()).format('YYYY'); 
    }, 

    getPreparedTitle: function(){
      return !this.document.title ?  
        "#{this.document.title} | #{this.site.title}"
        : this.site.title;
    },

    getPreparedDescription: function(){
      return this.document.description || this.site.description;
    },

    getPreparedTags: function(doc){
      var tags = [];
      if (doc.hasOwnProperty('tags')) {
        _.each(doc.tags, function(tag) {
          _.each(tag.split(","), function(t) {
            if (0 < t.length) {
              tags.push(t);
            }

          });

        });

      }
      return tags;
    },

    formatArchive: function(colls){
      var page = {};
      if (colls) {
        _.each(colls, function(col) {
          var y = col.date.getFullYear();
          if (y in page) {
            page[y].push(col);
          } else {
            page[y] = [col];
          }

        });
      }

      var sortList = [];
      _.each(page, function(val, year) {
        sortList.push(year);
      });
      page["list"] = _.sortBy(sortList, function(year) { return -year;});

      return page;
    },

    subArray: function(list, num) {
      return _.first(list, num);
    },

    formatDate: function(x) {
      return this.moment(x).format('MMMM Do YYYY, HH:mm');
    },

    shortenTitle: function(title){
      if (!title) {
        return "none";

      } else if (32 < title.length) {
        return (title.substring(0, 32)) + "...";

      } else {
        return title;

      }
    },
      
    getLatestPosts: function() {
      return _.first(this.getCollection("pages").toJSON(), 3);
    },

    getCuttedContent: function(content){            
      var i = content.search('<!-- more -->');
      if (i >= 0) {
        return _.first(content, i);                
      } else {
        return content;
      }
    },

    hasReadMore: function(content){
        return content.search('<!-- more -->') >= 0;
    }
  },

  collections: {
    pages: function (){
      return this.getCollection("html")
        .findAllLive({layout: "post"}, [{date: -1}]);
    },

    indexPages: function(){
      return this.getCollection("html")
        .findAllLive({layout: "post"}, [{date: -1}]);
    }
  },

  environments: { 
    development: { 
      enabled: false,
      templateData :  {
        include3rd : false,
        site: {
          url: "http://127.0.0.1:8080"
        }
      }
    },

    product: {
      enabled: true,
      templateData : { 
        site: {
          url: "http://127.0.0.1:8080"
        },
        include3rd : true
      }
    },

    // for github push
    deploy: {
      enabled: true,
      templateData : { 
        include3rd : true,
        site: {
          url: "http://oopschen.github.io"
        }
      }
    }
  }
  // env end

} // end
