// SPDX-License-Identifier: MIT

/**
 * @title UpgrBounSystem
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 */
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { PositionData } from "../codegen/index.sol";
import { UpgradeBounty } from "../codegen/index.sol";
import { OwnedBy } from "../codegen/index.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib, ROOT_NAMESPACE } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { IWorld as IPrimodiumWorld } from "../primodium-codegen/world/IWorld.sol";
import { LibHelpers } from "../libraries/LibHelpers.sol";
import { BuildingTileKey } from "../libraries/Keys.sol";

/**
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 * @notice Building owner must delegate to this contract to upgrade their building
 * @notice Technically users can deposit upgrade bounties at any coordinate, regardless of building existence
 * @notice Technically Alice can issue an upgrade bounty at Bob's building, and Bob can claim it
 */
contract YakuzaRevengeSystem is System {
  
  function sendResources() {
    // send the resource from orbit
    // on success if enough iron 
    // => set expiry and owner
  }

  function claim(bytes32 asteroidID) {
    // if expiry > ttimestamp
    // if owner[asteroidId]
   //if currentOwner != owner
   // send a full fleet to asteroidID orbit
  }

  function finalizeClainm(claimID) {
    // send from orbit to ground
  }
}
