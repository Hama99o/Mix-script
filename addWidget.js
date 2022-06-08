search.addWidget({
    render: function (opts) {
      var results = opts.results;

      if (!is_connected) {
        var categories_names = opts.state.hierarchicalFacetsRefinements.categories_names
        const is_categories_names_empty_or_undefined = categories_names === undefined || categories_names.length == 0
        const is_query_empty = opts.state.query.length === 0
        const is_first_page = results.page == 0

        initBlur(is_first_page)

        if (is_categories_names_empty_or_undefined && is_query_empty && is_first_page) {
          var count = 0
          const slicedArray = results.hits.forEach((item) => {
            count++
            if (count <= 3) {
              item.is_public = true
              console.log(item)
            }
          })
        }
      }
    }
  })
