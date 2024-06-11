// SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on local anvil chain
//2. Keep ttrack of the contract address across different chains
//Sepolia
//Mainnet

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/Mocks/MocksV3Aggregator.sol";


contract HelperConfig is Script{
    //If we are on a local anvil we deploy mocks
    //Otherwise grab the exixting address from the live network

    
    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed  address
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor (){//Havent added the mainnet functionality yet
        if (block.chainid == 11155111){
            activeNetworkConfig =  getSepoliaETHConfig();
        }else {
            activeNetworkConfig =  getOrCreateAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    
    //Mainnet funtionality not added yet
    /*function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory MainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return MainnetConfig;
    }*/

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        //Deploy mock contracts
        //Return mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator (DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed : address(mockPriceFeed)});
        return anvilConfig;
   }
}