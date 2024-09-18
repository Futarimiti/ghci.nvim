local GHCi = {}

-- Spawn a GHCi session.
GHCi.spawn = require('ghci.core.session').spawn

-- Attach a GHCi session to a window.
GHCi.attach = require('ghci.core.attach').attach

return GHCi
