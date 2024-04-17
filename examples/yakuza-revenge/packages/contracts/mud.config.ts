import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "yakuzaRevenge",
  systems: {
    YakuzaRevengeSystem: {
      openAccess: true,
      name: "YakuzaRevengeSystem",
      // deposits and withdrawals track the depositor and amount
    },
  },
  tables: {
    YakuzaServiceExpiry: {
      keySchema: {
        asteroid: "bytes32",
      },
      valueSchema: {
        expiry: "uint256",
        owner: "address"
      }
    },
    YakuzaServicePendingClaim: {
      keySchema: {
        claimID: "bytes32",
      },
      valueSchema: {
        asteroidID: "bytes32",
        fleetID: "bytes32"
      }
    },

    IsYakuzaAsteroid: {
      keySchema: {
        asteroid: "bytes32",
      },
      valueSchema: {
        base: "bool",
      }
    },

    /* --------------------------------- Common --------------------------------- */
    Position: {
      keySchema: { entity: "bytes32" },
      valueSchema: {
        x: "int32",
        y: "int32",
        parent: "bytes32",
      },
    },

    OwnedBy: {
      keySchema: { entity: "bytes32" },
      valueSchema: {
        value: "bytes32",
      },
    },
  },
});
