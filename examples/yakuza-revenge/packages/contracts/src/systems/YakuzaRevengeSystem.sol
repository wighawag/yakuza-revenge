// SPDX-License-Identifier: MIT

/**
 * @title UpgrBounSystem
 * @dev A contract that handles upgrade bounties for buildings in a world system.
 */
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { YakuzaClaims, YakuzaClaimsData, IsYakuzaAsteroid, YakuzaServicePendingClaim, YakuzaServicePendingClaimData } from "../codegen/index.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib, ROOT_NAMESPACE } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { IWorld as IPrimodiumWorld } from "../primodium-codegen/world/IWorld.sol";
import { LibHelpers } from "../libraries/LibHelpers.sol";
// import { BuildingTileKey } from "../libraries/Keys.sol";

// import { ResourceCount } from "../codegen/index.sol";
import { EResource } from "../primodium-codegen/common.sol";
import {IFleetMoveSystem} from "../primodium-codegen/world/IFleetMoveSystem.sol";


import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

/**
 * @notice A contract that let player share a fleet army under control of a smart contract 
 * @notice THis can be used to cpature an asteroid back
 */
contract YakuzaRevengeSystem is System {

  /**
   * @notice Send the resouce from orbit. On success if enough iron. Then, set expiry.
   * @param fleetID The fleet already in orbit, used to send the resources as payment for Yakuza service
   * @param toProtectAsteroidID the asteroid who get the protection
   * @param yakuzaAsteroidID the yakuza asteroid that own the protection fleets
   * @param resourceValue the amount to send as payment
   */
  function sendResources(bytes32 fleetID, bytes32 toProtectAsteroidID, bytes32 yakuzaAsteroidID, uint256 resourceValue) external{
    IWorld world = IWorld(_world());
    // IWorld(_world).YakuzaRevenge_YakuzaSystem_IsYakuzaAsteroid 
    bytes32 playerEntity = LibHelpers.addressToEntity(_msgSender());
    // check if the player has enough iron
    // require(IWorld(_world).Primodium_PrimodiumSystem_ResourceCount.get(playerEntity, EResource.Iron) > resourceValue, "You don't have enough iron");


    require(IsYakuzaAsteroid.get(yakuzaAsteroidID), "YakuzaAsteroid is not owned by Yakuza");


    uint256[] memory resourceCounts = new uint256[](2);
    resourceCounts[0] = uint256(EResource.Iron);
    resourceCounts[1] = resourceValue;


    // transfer the resources from the player to the yakuzaAsteroid
    
    ResourceId fleetTransferSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "FleetTransferSys");
    IPrimodiumWorld(_world()).call(fleetTransferSystemId,
      abi.encodeWithSignature("transferResourcesFromFleetToSpaceRock(bytes32,bytes32,uint256[])", fleetID, yakuzaAsteroidID, resourceCounts));

    uint64 extra = uint64(block.timestamp + 1 days * (resourceValue));

    address asteroidOwner = address(uint160(uint256(OwnedBy.get(toProtectAsteroidID))));
    
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

    StoreSwitch.setStoreAddress("0xd5d9aad645671a285d1cadf8e68aef7d74a8a7d0"); // sets the store address to the world address
    address asteroidOwner = address(uint160(uint256(OwnedBy.get(asteroidID))));

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
    StoreSwitch.setStoreAddress("0xd5d9aad645671a285d1cadf8e68aef7d74a8a7d0"); // sets the store address to the world address
    Iworld world = IWorld(_world());

    require(IsYakuzaAsteroid.get(yakuzaAsteroidID), "not yakuza");
    
    YakuzaClaimsData memory claimData = YakuzaClaims.get(asteroidID);
    
    require(claimData.expiry  > block.timestamp(), "expired");
    require(!claimData.claimed, "already claimed");

    address member = claimData.owner;  
    address currentAsteroidOwner = address(uint160(uint256(OwnedBy.get(asteroidID))));

    require(currentAsteroidOwner != member, "asteroid not lost");

    claimData.claimed = true;
    YakuzaClaims.set(asteroidID, claimData);
    ResourceId fleetMoveSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "FleetMoveSystem");
    bytes memory data = IPrimodiumWorld(_world()).call(fleetMoveSystemId,
      abi.encodeWithSignature("sendFleet(bytes32,bytes32)", yakuzaAsteroidID, asteroidID)
    );
    bytes32 fleetID = abi.decode(data, (bytes32)); // is that the right  way?
    
    // claimID
    YakuzaServicePendingClaim.set(asteroidID, YakuzaServicePendingClaimData({
      asteroidID: asteroidID,
      yakuzaAsteroidID: yakuzaAsteroidID,
      fleetID: fleetID,
      sent: false
    }));

  }


  /// @notice to call after the fleet arrive in orbit (as a result of calling `claim`)
  /// @param claimID claimId representing the pending claim
  function finalizeClaim(bytes32 claimID) external{
    // send from orbit to ground
    YakuzaServicePendingClaimData memory pendingClaim = YakuzaServicePendingClaim.get(claimID);
    bytes32 asteroidID = pendingClaim.asteroidID;
    require(asteroidID != bytes32(0), "no pending claim");
    require(!pendingClaim.sent, "already sent");
  
    pendingClaim.sent = true;
    ResourceId fleetCombatSystemID = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "IFleetCombatSystem");
    bytes memory data = IPrimodiumWorld(_world()).call(fleetCombatSystemID,
      abi.encodeWithSignature("attack(bytes32,bytes32)", pendingClaim.fleetID, asteroidID)
    );
  }

   /// @notice to call after claim is finalize to return fleet to base if any
  /// @param claimID claimId representing the pending claim
  function returnFleet(bytes32 claimID) external{
    
    ResourceId fleetMoveSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "FleetMoveSystem");
    bytes memory data = IPrimodiumWorld(_world()).call(fleetMoveSystemId,
      abi.encodeWithSignature("sendFleet(bytes32,bytes32)", asteroidID, yakuzaAsteroidID)
    );
  }

  // should be called on return ?
  // function mergeFleet(bytes32 claimID) external{
    
  //   ResourceId fleetMoveSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, ROOT_NAMESPACE, "FleetMoveSystem");
  //   bytes memory data = IPrimodiumWorld(_world()).call(fleetMoveSystemId,
  //     abi.encodeWithSignature("sendFleet(bytes32,bytes32)", yakuzaAsteroidID, asteroidID)
  //   );
  // }


  // function spawnYakuza() external {

  // }
}
