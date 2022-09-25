pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "../TicTacToken.sol";

contract Caller {

    TicTacToken internal ttt;

    constructor(TicTacToken _ttt) {
        ttt = _ttt;
    }
    function call() public view returns (address) {
        return ttt.msgSender();
    }
}

contract TicTacTokenTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    TicTacToken internal ttt;
    address internal constant OWNER = address(1);

    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;

    address public owner;

    function setUp() public{
        ttt = new TicTacToken(OWNER);
    }

    function test_contract_owner() public {
        assertEq(ttt.owner(), OWNER);
    }

    function test_owner_can_reset_board() public {
        vm.prank(OWNER);
        ttt.resetBoard();
    }

    function test_non_owner_cannot_reset_board() public {
        vm.expectRevert("Unauthorized");
        ttt.resetBoard();
    }

    function test_msg_sender() public {
        Caller caller1 = new Caller(ttt);
        Caller caller2 = new Caller(ttt);

        assertEq(ttt.msgSender(), address(this));

        assertEq(caller1.call(), address(caller1));
        assertEq(caller2.call(), address(caller2));
    }

    function test_has_empty_board() public {
        for (uint256 i=0; i<9; i++) {
            assertEq(ttt.board(i), EMPTY);
        }
    }

    function test_get_board() public {
        uint256[9] memory expected = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY];
        uint256[9] memory actual = ttt.getBoard();

        for (uint256 i=0; i<9; i++) {
            assertEq(actual[i], expected[i]);
        }
    }

     function test_can_mark_space_with_X() public {
        ttt.markSpace(0, X);
        assertEq(ttt.board(0), X);
    }

    function test_can_mark_space_with_O() public {
        ttt.markSpace(0, X);
        ttt.markSpace(1, O);
        assertEq(ttt.board(1), O);
    }

    function test_cannot_mark_space_with_Z() public {
        vm.expectRevert("Invalid symbol");
        ttt.markSpace(0, 3);
    }

    function test_cannot_overwrite_marked_space() public {
        ttt.markSpace(0, X);
        
        vm.expectRevert("Already marked");
        ttt.markSpace(0, O);
    }

    function test_symbols_must_alternate() public {
        ttt.markSpace(0, X);
        vm.expectRevert("Not your turn");
        ttt.markSpace(1, X);
    }

    function test_tracks_current_turn() public {
        assertEq(ttt.currentTurn(), X);
        ttt.markSpace(0, X);
        assertEq(ttt.currentTurn(), O);
        ttt.markSpace(1, O);
        assertEq(ttt.currentTurn(), X);
    }

    function test_checks_for_horizontal_win() public {
    ttt.markSpace(0, X);
    ttt.markSpace(3, O);
    ttt.markSpace(1, X);
    ttt.markSpace(4, O);
    ttt.markSpace(2, X);
    assertEq(ttt.winner(), X);
  }

  function test_checks_for_horizontal_win_row2() public {
    ttt.markSpace(3, X);
    ttt.markSpace(0, O);
    ttt.markSpace(4, X);
    ttt.markSpace(1, O);
    ttt.markSpace(5, X);
    assertEq(ttt.winner(), X);
  }

    function test_checks_for_vertical_win() public {
    ttt.markSpace(1, X);
    ttt.markSpace(0, O);
    ttt.markSpace(2, X);
    ttt.markSpace(3, O);
    ttt.markSpace(4, X);
    ttt.markSpace(6, O);
    assertEq(ttt.winner(), O);
  }

  function test_draw_returns_no_winner() public {
    ttt.markSpace(4, X);
    ttt.markSpace(0, O);
    ttt.markSpace(1, X);
    ttt.markSpace(7, O);
    ttt.markSpace(2, X);
    ttt.markSpace(6, O);
    ttt.markSpace(8, X);
    ttt.markSpace(5, O);
    assertEq(ttt.winner(), 0);
  }

  function test_empty_board_returns_no_winner() public {
    assertEq(ttt.winner(), 0);
  }

  function test_game_in_progress_returns_no_winner() public {
    ttt.markSpace(1, X);
    assertEq(ttt.winner(), 0);
  }

}