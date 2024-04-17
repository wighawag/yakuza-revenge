// SPDX-License-Identifier: MIT

/**
 * @title UpgrBounSystem
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 */
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { YakuzaClaims, IsYakuzaAsteroid,YakuzaServicePendingClaim } from "../codegen/index.sol";
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
  function sendResources(bytes32 fleetID, bytes32 toProtectAsteroidID, bytes32 yakuzaAsteroidID, uint256 resourceValue) external{

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


    require(IsYakuzaAsteroid.get(yakuzaAsteroidID), "YakuzaAsteroid is not owned by Yakuza");


    uint256[] memory resourceCounts = new uint256[](2);
    resourceCounts[0] = EResource.Iron;  // 一つ目のリソースのカウント
    resourceCounts[1] = resourceValue; // 二つ目のリソースのカウント
    
    // transfer the resources from the player to the yakuzaAsteroid
    require(IFleetMoveSystem.transferResourcesFromFleetToSpaceRock(fleetID, yakuzaAsteroidID, resourceCounts),
      "Failed to transfer resources from fleet to space rock");

    uint64 extra = block.timestamp + 1 days * (resourceValue);

    address asteroidOwner = address(0); //  toProtectAsteroidID
    
    // record the depositor entity, yakuzaEntity, and value in the YakuzaRevenge table
    YakuzaClaimsData memory data = YakuzaClaims.get(toProtectAsteroidID);
    require(data.owner == asteroidOwner || data.owner == address(0) || data.expiry < block.timestamp, "claim already owned");
    data.expiry = data.expiry < block.timestamp ? block.timestamp + extra : expiry + extra;
    data.owner = asteroidOwner;
    data.claimed = false;
    YakuzaClaims.set(asteroidID, data);
  }

  /// @notice to be called when you previously claimed a revenge attack but the revenge did not manage to capture the atseroid back
  ///  and you capture back by your own means. This is to allow the Yakuza System to know that you can claim again if you lost the asteroid again.
  /// @param asteroidID asteroid to reclaim protection for
  function notifyOwnership(bytes32 asteroidID) external {
    address asteroidOwner = address(0); //  asteroidID

    YakuzaClaimsData memory data = YakuzaClaims.get(asteroidID);
    require(data.owner == asteroidOwner && data.expiry > block.timestamp, "claim not owned");
    data.claimed = false;
    YakuzaClaims.set(asteroidID, data);
  }

  /// @notice to be called when you lose a registered asterattack but the revenge did not manage to capture the atseroid back
  ///  and you capture back by your own means. This is to allow the Yakuza System to know that you can claim again if you lost the asteroid again.
  /// @param yakuzaAsteroidID asteroid owned by yakuza from which to send the fleet
  /// @param asteroidID asteroid to capture back
  function claim(bytes32 yakuzaAsteroidID, bytes32 asteroidID)external {
    Iworld world = IWorld(_world());

    if (IsYakuzaAsteroid.get(yakuzaAsteroidID)) {
      YakuzaClaimsData memory claimData = YakuzaClaims.get(asteroidID);
      if (claimData.expiry  > block.timestamp() && !claimData.claimed) {
        address member = claimData.owner;
        if (member == _msgSender()) {
          address currentAsteroidOwner =  address(0); // TODO
          if (currentAsteroidOwner == member) {
            // Call the upgradeBuilding function from the World contract
            ResourceId fleetMoveSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "FleetMoveSystem");
            IPrimodiumWorld(_world()).call(fleetMoveSystemId,
              abi.encodeWithSignature("sendFleet(bytes32,bytes32)", yakuzaAsteroidID, asteroidID)
            );
          }
        }
        
      }
    }
   
    
  }


  /// @notice to call after the fleet arrive in orbit (as a result of calling `claim`)
  /// @param claimID claimId representing the pending claim
  function finalizeClainm(bytes32 claimID) external{
    // send from orbit to ground
  }
}
