local jdtls = require('jdtls')

local root_markers = { 'pom.xml', '.git', 'mvnw' }
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then return end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspaces/' .. project_name

local mason_pkg = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local launcher = vim.fn.glob(mason_pkg .. '/plugins/org.eclipse.equinox.launcher_*.jar')
local config_dir = mason_pkg .. '/config_linux' 

local capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities()
)

local config = {
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', launcher,
        '-configuration', config_dir,
        '-data', workspace_dir,
    },
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
        java = {
            format = { enabled = false },
            -- Don't let jdtls's Eclipse compiler write into target/classes (Maven's output dir).
            -- With autobuild on, jdtls leaves stale/broken .class files there that `mvn` then packages
            -- (e.g. "Unresolved compilation problem" at runtime). Off = Maven owns target/classes alone.
            -- Diagnostics/completion still work via the reconciler.
            autobuild = { enabled = false },
        },
    },
    init_options = {
        bundles = {},
    },
}

jdtls.start_or_attach(config)
