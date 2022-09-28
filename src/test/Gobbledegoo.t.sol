pragma solidity >=0.8.0;

import "forge-std/console.sol";

import {Gobbledegoo} from "../Gobbledegoo.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Vm} from "2022-09-artgobblers.git/../lib/forge-std/src/Vm.sol";
import {stdError} from "2022-09-artgobblers.git/../lib/forge-std/src/Test.sol";
import {ArtGobblers, FixedPointMathLib} from "2022-09-artgobblers.git/ArtGobblers.sol";
import {Goo} from "2022-09-artgobblers.git/Goo.sol";
import {Pages} from "2022-09-artgobblers.git/Pages.sol";
import {GobblerReserve} from "2022-09-artgobblers.git/utils/GobblerReserve.sol";
import {Utilities} from "2022-09-artgobblers.git/../test/utils/Utilities.sol";
import {ChainlinkV1RandProvider} from "2022-09-artgobblers.git/utils/rand/ChainlinkV1RandProvider.sol";
import {RandProvider} from "2022-09-artgobblers.git/utils/rand/RandProvider.sol";
import {VRFCoordinatorMock} from "2022-09-artgobblers.git/../lib/chainlink/contracts/src/v0.8/mocks/VRFCoordinatorMock.sol";
import {LinkToken} from "2022-09-artgobblers.git/../test/utils/mocks/LinkToken.sol";
import {LibString} from "solmate/utils/LibString.sol";

contract GobbledegooTest is DSTestPlus {
    using LibString for uint256;

    Gobbledegoo internal gobbledegoo;

    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    ArtGobblers internal gobblers;
    GobblerReserve internal team;
    GobblerReserve internal community;
    Utilities internal utils;
    RandProvider internal randProvider;
    VRFCoordinatorMock internal vrfCoordinator;
    LinkToken internal linkToken;
    Goo internal goo;
    Pages internal pages;

    bytes32 private keyHash;
    uint256 private fee;
    address payable[] internal users;

    function setUp() public{

        utils = new Utilities();
        users = utils.createUsers(5);
        linkToken = new LinkToken();
        vrfCoordinator = new VRFCoordinatorMock(address(linkToken));

        address gobblerAddress = utils.predictContractAddress(address(this), 4);
        address pagesAddress = utils.predictContractAddress(address(this), 5);

        team = new GobblerReserve(ArtGobblers(gobblerAddress), address(this));
        community = new GobblerReserve(ArtGobblers(gobblerAddress), address(this));
        randProvider = new ChainlinkV1RandProvider(
            ArtGobblers(gobblerAddress),
            address(vrfCoordinator),
            address(linkToken),
            keyHash,
            fee
        );

        goo = new Goo(
            // Gobblers:
            utils.predictContractAddress(address(this), 1),
            // Pages:
            utils.predictContractAddress(address(this), 2)
        );

        gobblers = new ArtGobblers(
            keccak256(abi.encodePacked(users[0])),
            block.timestamp,
            goo,
            Pages(pagesAddress),
            address(team),
            address(community),
            randProvider,
            "base",
            ""
        );

        gobbledegoo = new Gobbledegoo(gobblers);

        pages = new Pages(block.timestamp, goo, address(0xBEEF), gobblers, "");
    }

    function testGobble() public {
        gobbledegoo.gobble();
    }

    function testDepositGobbler() public {
        mintGobblerToAddress(users[0], 1);
        vm.warp(block.timestamp + 1 days);
        setRandomnessAndReveal(1, "seed");

        //Deposit specified gobbler in gobbledegoo contract.
        vm.prank(users[0]);
        gobblers.approve(address(gobbledegoo), 1);
        
        vm.prank(users[0]);
        gobbledegoo.depositGobbler(1);

        //vm.warp(block.timestamp + 1 days);
        console.logUint(gobblers.gooBalance(address(gobbledegoo)));
    }

    //HELPERS
    function setRandomnessAndReveal(uint256 numReveal, string memory seed) internal {
        bytes32 requestId = gobblers.requestRandomSeed();
        uint256 randomness = uint256(keccak256(abi.encodePacked(seed)));
        // call back from coordinator
        vrfCoordinator.callBackWithRandomness(requestId, randomness, address(randProvider));
        gobblers.revealGobblers(numReveal);
    }

    function mintGobblerToAddress(address addr, uint256 num) internal {
        for (uint256 i = 0; i < num; i++) {
            vm.startPrank(address(gobblers));
            goo.mintForGobblers(addr, gobblers.gobblerPrice());
            vm.stopPrank();

            uint256 gobblersOwnedBefore = gobblers.balanceOf(addr);

            vm.prank(addr);
            gobblers.mintFromGoo(type(uint256).max, false);

            assertEq(gobblers.balanceOf(addr), gobblersOwnedBefore + 1);
        }
    }
}