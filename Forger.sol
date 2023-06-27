pragma solidity ^0.8.19;

import {ERC1155_} from "./ERC1155_.sol";
import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Forger is Ownable {

    ERC1155_ public erc1155_;
    mapping(bytes32 => bool) public forges;

    event Forge(
        address indexed _account,
        bytes32 indexed _forgeId,
        uint _multiplier
    );

    event Rule(
        bytes32 indexed _forgeId,
        uint[] forgeInIds,
        uint[] forgeInAmounts,
        uint[] forgeOutIds,
        uint[] forgeOutAmounts
    );

    function setERC1155(address _erc1155) public onlyOwner {

        erc1155_ = ERC1155_(_erc1155);
    }

    function forge(
        uint[] memory forgeInIds,
        uint[] memory forgeInAmounts,
        uint[] memory forgeOutIds,
        uint[] memory forgeOutAmounts
    ) public {

        _forge(forgeInIds, forgeInAmounts, forgeOutIds, forgeOutAmounts, 1);
    }

    function forge(
        uint[] memory forgeInIds,
        uint[] memory forgeInAmounts,
        uint[] memory forgeOutIds,
        uint[] memory forgeOutAmounts,
        uint multiplier
    ) public {

        require(multiplier != 0, "Multiplier must be non-zero.");

        _forge(
            forgeInIds,
            forgeInAmounts,
            forgeOutIds,
            forgeOutAmounts,
            multiplier
        );
    }

    function rule(
        uint[] memory forgeInIds,
        uint[] memory forgeInAmounts,
        uint[] memory forgeOutIds,
        uint[] memory forgeOutAmounts
    ) public onlyOwner {

        bytes32 forgeId = _forgeId(
            forgeInIds,
            forgeInAmounts,
            forgeOutIds,
            forgeOutAmounts
        );

        forges[forgeId] = true;

        emit Rule(
            forgeId,
            forgeInIds,
            forgeInAmounts,
            forgeOutIds,
            forgeOutAmounts
        );
    }

    function _forge(
        uint[] memory forgeInIds,
        uint[] memory forgeInAmounts,
        uint[] memory forgeOutIds,
        uint[] memory forgeOutAmounts,
        uint multiplier
    ) private {

        bytes32 forgeId = _forgeId(
            forgeInIds,
            forgeInAmounts,
            forgeOutIds,
            forgeOutAmounts
        );

        require(forges[forgeId], "Invalid forge.");

        if (multiplier != 1) {

            forgeInAmounts = _multiply(forgeInAmounts, multiplier);

            forgeOutAmounts = _multiply(forgeOutAmounts, multiplier);
        }

        erc1155_.burnBatch(msg.sender, forgeInIds, forgeInAmounts);

        erc1155_.mintBatch(msg.sender, forgeOutIds, forgeOutAmounts, "");

        emit Forge(msg.sender, forgeId, multiplier);
    }

    function _forgeId(
        uint[] memory forgeInIds,
        uint[] memory forgeInAmounts,
        uint[] memory forgeOutIds,
        uint[] memory forgeOutAmounts
    ) private pure returns (bytes32) {

        return
            keccak256(
                abi.encode(
                    forgeInIds,
                    forgeInAmounts,
                    forgeOutIds,
                    forgeOutAmounts
                )            
            );
    }

    function _multiply(
        uint[] memory numbers,
        uint multiplier
    ) private pure returns (uint[] memory) {

        uint[] memory result = new uint[](numbers.length);

        for (uint i = 0; i < numbers.length; i++) {
            
            result[i] = multiplier * numbers[i];
        }

        return result;
    }
}
