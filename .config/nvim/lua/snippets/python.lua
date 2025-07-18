local ls   = require("luasnip")
local snip = ls.snippet
local text = ls.text_node

return {
    ----------------------------------------------------
    snip('main', 
        {
            text({
                "if __name__ == '__main__':", 
                "    main()" }),
        }),
    ----------------------------------------------------
    snip('logger', 
        {
            text({
                "from dmu.logging.log_store import LogStore", 
                "",
                "log=LogStore.add_logger('')" }),

        }),
    ----------------------------------------------------
    snip('data_class', 
        {
            text({
                "class Data", 
                "'''", 
                "Class meant to be used to share attributes", 
                "'''" }),

        }),
    ----------------------------------------------------
}
