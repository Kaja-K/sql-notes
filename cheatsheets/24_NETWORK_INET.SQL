--  Data types:
--    inet  — stores an IPv4/IPv6 host address WITH optional subnet
--    cidr  — stores a network address (host bits must be zero)
--    macaddr — stores a MAC address

-- ── CASTING / DECLARING ──────────────────────────────────────
SELECT '192.168.1.100/24'::inet;          -- cast text to inet
SELECT '10.0.0.0/8'::cidr;               -- cast text to cidr

-- ── ADDRESS COMPONENTS ───────────────────────────────────────
SELECT host('192.168.1.100/24'::inet);
-- → '192.168.1.100'         strips prefix, returns IP as text

SELECT masklen('192.168.1.100/24'::inet);
-- → 24                      returns the prefix length (subnet mask)

SELECT netmask('192.168.1.100/24'::inet);
-- → '255.255.255.0'         returns subnet mask in dotted notation

SELECT family('192.168.1.100'::inet);
-- → 4                       returns 4 (IPv4) or 6 (IPv6)

SELECT abbrev('10.0.0.0/8'::inet);
-- → '10.0.0.0/8'            abbreviated display form

-- ── NETWORK BOUNDARIES ───────────────────────────────────────
SELECT network('192.168.1.100/24'::inet);
-- → '192.168.1.0/24'        zeroes out host bits → first (network) address

SELECT broadcast('192.168.1.100/24'::inet);
-- → '192.168.1.255/24'      sets all host bits to 1 → last (broadcast) address

-- Simplified — returns inet type directly (includes prefix):
SELECT
    id,
    network(ip_address)   AS first_address,   -- → 182.240.42.0/24
    broadcast(ip_address) AS last_address      -- → 182.240.42.255/24
FROM connections
ORDER BY id;

-- With host() — strips prefix, returns plain text + manual suffix:
SELECT
    id,
    host(network(ip_address))   || '/' || masklen(ip_address) AS first_address,
    host(broadcast(ip_address)) || '/' || masklen(ip_address) AS last_address
FROM connections
ORDER BY id;
-- Example — ip_address = 182.240.42.115/24
--   first_address → '182.240.42.0/24'
--   last_address  → '182.240.42.255/24'

-- ── CONTAINMENT / OVERLAP ────────────────────────────────────
SELECT '192.168.1.100'::inet << '192.168.1.0/24'::inet;
-- → true     <<  means "is contained within network"

SELECT '192.168.1.0/24'::inet >> '192.168.1.5'::inet;
-- → true     >>  means "contains address or network"

SELECT '192.168.0.0/23'::inet &&  '192.168.1.0/24'::inet;
-- → true     &&  means "networks overlap"

-- Practical: find all rows whose IP belongs to a given subnet
SELECT * FROM connections
WHERE ip_address << '10.0.0.0/8'::inet;

-- ── ARITHMETIC ───────────────────────────────────────────────
SELECT '192.168.1.0'::inet + 5;
-- → '192.168.1.5'           add an integer offset to an address

SELECT '192.168.1.255'::inet - '192.168.1.0'::inet;
-- → 255                     difference between two addresses (bigint)

-- Walk through all usable host IPs in a /24 (1–254):
SELECT host('192.168.1.0'::inet + i) AS ip
FROM generate_series(1, 254) AS i;

-- ── SET / STRIP PREFIX ───────────────────────────────────────
SELECT set_masklen('192.168.1.100/24'::inet, 16);
-- → '192.168.1.100/16'      change prefix length

SELECT set_masklen('192.168.1.100/24'::cidr, 16);
-- → '192.168.0.0/16'        on cidr, host bits are zeroed automatically

-- ── TEXT ↔ INET ──────────────────────────────────────────────
SELECT host(ip_address) FROM connections;         -- inet  → plain text IP
SELECT ip_address::text  FROM connections;        -- inet  → '1.2.3.4/24' text
SELECT '10.0.0.1'::inet;                          -- text  → inet

-- ── MACADDR ──────────────────────────────────────────────────
SELECT '12:34:56:78:90:ab'::macaddr;              -- cast to macaddr
SELECT trunc('12:34:56:78:90:ab'::macaddr);
-- → '12:34:56:00:00:00'     zeroes out last 3 octets (OUI prefix only)