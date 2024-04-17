// SPDX-License-Identifier: MIT

/**
 * @title UpgrBounSystem
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 */
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
// import { PositionData } from "../codegen/index.sol";
// import { UpgradeBounty } from "../codegen/index.sol";
// import { OwnedBy } from "../codegen/index.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
// import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib, ROOT_NAMESPACE } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { IWorld as IPrimodiumWorld } from "../primodium-codegen/world/IWorld.sol";
import { LibHelpers } from "../libraries/LibHelpers.sol";
// import { BuildingTileKey } from "../libraries/Keys.sol";

// import { ResourceCount } from "../codegen/index.sol";
import { EResource } from "../primodium-codegen/common.sol";
import {IFleetMoveSystem} from "../primodium-codegen/world/IFleetMoveSystem.sol";

/**
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 * @notice Building owner must delegate to this contract to upgrade their building
 * @notice Technically users can deposit upgrade bounties at any coordinate, regardless of building existence
 * @notice Technically Alice can issue an upgrade bounty at Bob's building, and Bob can claim it
 */
contract YakuzaRevengeSystem is System {

  /**
   * @dev Send the resouce from orbit. On success if enough iron. Then, set expiry.
   */
  function sendResources(bytes32 fleetID, bytes32 yakuzaAsteroidID, uint256 resourceValue) external{

    // EResource.Iron;

    // function transferResourcesFromFleetToSpaceRock(
    //   bytes32 fleetId,
    //   bytes32 spaceRock,
    //   uint256[] calldata resourceCounts
    // ) external;

    IWorld world = _world();
    // IWorld(_world).YakuzaRevenge_YakuzaSystem_IsYakuzaAsteroid 

    bytes32 playerEntity = LibHelpers.addressToEntity(_msgSender());


    // check if the player has enough iron
    // require(IWorld(_world).Primodium_PrimodiumSystem_ResourceCount.get(playerEntity, EResource.Iron) > resourceValue, "You don't have enough iron");


    // check yakuzaAsteroidID is owned by no one or yakuza contract.
    if (IsYakuzaAsteroid.get(yakuzaAsteroidID) == false) {
      // check if the asteroid is free
      // require(IsFleetEmpty(yakuzaAsteroidID), "That asteroid is not empty");
      
      // set the asteroid to be owned by the yakuza
      IsYakuzaAsteroid.set(yakuzaAsteroidID, true);
    }

    require(IsYakuzaAsteroid.get(yakuzaAsteroidID) == true, "YakuzaAsteroid is not owned by Yakuza");


    uint256[] memory resourceCounts = new uint256[](2);
    resourceCounts[0] = EResource.Iron;  // 一つ目のリソースのカウント
    resourceCounts[1] = resourceValue; // 二つ目のリソースのカウント
    
    // transfer the resources from the player to the yakuzaAsteroid
    require(IFleetMoveSystem.transferResourcesFromFleetToSpaceRock(fleetID, yakuzaAsteroidID, resourceCounts),
      "Failed to transfer resources from fleet to space rock");

    uint64 expiry = block.timestamp + 1 days * (resourceValue);

    // record the depositor entity, yakuzaEntity, and value in the YakuzaRevenge table
    YakuzaServiceExpiry.set(yakuzaAsteroid, expiry, playerEntity);
  }

  function claim(bytes32 asteroidID)external {
    // IFleetMoveSystem.sendFleet
    // uint64 expiry =
    // if expiry > ttimestamp
    // if owner[asteroidId]
   //if currentOwner != owner
   // send a full fleet to asteroidID orbit
  }

  function finalizeClainm(bytes32 claimID) external{
    // send from orbit to ground
  }
}
