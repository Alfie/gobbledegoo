pragma solidity >=0.8.0;

import {ArtGobblers, FixedPointMathLib} from "2022-09-artgobblers.git/ArtGobblers.sol";
import {LibString} from "solmate/utils/LibString.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC721Receiver.sol";
import {GobblersERC721} from "2022-09-artgobblers.git/utils/token/GobblersERC721.sol";

contract Gobbledegoo {
    using LibString for uint256;
    using FixedPointMathLib for uint256;

    enum ProjectState {newEscrow, nftDeposited, cancelNFT, ethDeposited, canceledBeforeDelivery, deliveryInitiated, delivered}

    ArtGobblers public immutable gobblers;
    ProjectState public projectState;

    constructor(
        ArtGobblers _gobblers
    ){
        gobblers = _gobblers;
    }

    //seller deposits Gobbler to produce goo
    function depositGobbler(uint256 gobblerID) public{
        gobblers.transferFrom(msg.sender, address(this), gobblerID);
    }

    function depositGoo() public {

    }

    //buyer deposits ETH for exchange for goo produced
    function depositETH() public payable{

    }

    function gobble() public{
        //TODO: initialize user renting out gobblers goo producction.

        //TODO: initialize goo production renter.

        uint256 initialBalance = gobblers.gooBalance(msg.sender);
    }

}