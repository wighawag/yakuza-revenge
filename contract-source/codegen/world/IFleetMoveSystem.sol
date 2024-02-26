// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

import { PositionData } from "codegen/index.sol";

/**
 * @title IFleetMoveSystem
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IFleetMoveSystem {
  function sendFleet(bytes32 fleetId, PositionData memory position) external;

  function sendFleet(bytes32 fleetId, bytes32 spaceRock) external;
}
