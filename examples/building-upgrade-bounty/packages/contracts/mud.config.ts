import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "upgradeBounty",
  systems: {
    UpgrBounSystem: {
      openAccess: true,
      name: "UpgrBounSystem",
      // deposits and withdrawals track the depositor and amount
    },
  },
  tables: {
    YakuzaServiceExpiry: {
      keySchema: {
        asteroid: "bytes32",
      },
      valueSchema: {
        expiry: "uint64",
        owner: "address"
      }
    },

    /* --------------------------------- Common --------------------------------- */
  },
});
