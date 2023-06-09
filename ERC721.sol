// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC721.sol";
import "./Address.sol";

contract ERC721 is IERC721
{
    using Address for address;
    
    event Transfer(address indexed from,address indexed to,uint indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);

    mapping (uint=>address) private _owners;

    mapping (address=>uint) private _balances;
    
    mapping (uint=>address) private _tokenApprovals;

    mapping (address=>mapping (address=>bool))private _operatorApprovals;

    function getInterfaceIdIERC721()public pure returns (bytes4)
    {
        return type(IERC721).interfaceId;
    } 

    function getInterfaceIdIERC165()public pure returns (bytes4)
    {
        return type(IERC165).interfaceId;
    }

    function supportsInterface(bytes4 interfaceId)
    external pure returns (bool)
    {
        return 
        interfaceId==type(IERC721).interfaceId || 
        interfaceId==type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external view returns(uint)
    {
        require(owner!=address(0),"owner=zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view returns (address owner)
    {
        owner=_owners[tokenId];
        require(owner!=address(0),"token doesn't exist");
    }

    function isApprovedForAll(address owner,address operator)external view returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator,bool approved) external 
    {
        _operatorApprovals[msg.sender][operator]=approved;
        emit ApprovalForAll(msg.sender,operator,approved);
    }

    function getApproved(uint tokenId)external  view returns(address)
    {
        require(_owners[tokenId]!=address(0),"token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function _approve(address owner,address to,uint tokenId)private {
        _tokenApprovals[tokenId]=to;
        emit Approval(owner, to, tokenId);
    }

    function approve(address to,uint tokenId) external 
    {
        address owner=_owners[tokenId];
        require(msg.sender==owner || _operatorApprovals[owner][msg.sender],
        "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId) 
        private view returns (bool)
    {
        return (spender==owner || 
        _tokenApprovals[tokenId]==spender || 
        _operatorApprovals[owner][spender]);
    }

function _transfer(
    address owner,
    address from,
    address to,
    uint tokenId
)private { 
    require(from==owner,"not owner");
    require(to!=address(0),"transfer to the zero address");
    _approve(owner,address(0),tokenId);
    _balances[from]-=1;
    _balances[to]+=1;
    _owners[tokenId]=to;
    emit Transfer(from,to,tokenId);
}

function transferFrom(
    address from,
    address to,
    uint tokenId
)external {
    address owner=ownerOf(tokenId);
    require(_isApprovedOrOwner(owner,msg.sender,tokenId),"not owner nor approved");
    _transfer(owner, from, to, tokenId);
}
function _checkOnERC721Received(
    address from,
    address to,
    uint tokenId,
    bytes memory _data
)private returns (bool)
{
    if(to.isContract()){
        return IERC721Receiver(to).onERC721Received(
            msg.sender,
            from,
            tokenId,
            _data
        )==IERC721Receiver.onERC721Received.selector;
    }else {
        return true;
    }
}

function _safeTransfer(
    address owner,
    address from,
    address to,
    uint tokenId,
    bytes memory _data
)private {
    _transfer(owner,from,to,tokenId);
    require(_checkOnERC721Received(from,to,tokenId,_data),
    "not ERC721Receiver"
    );
}

function safeTransferFrom(
    address from,
    address to,
    uint tokenId,
    bytes memory _data
)public {
    address owner=ownerOf(tokenId);
    require(
        _isApprovedOrOwner(owner,msg.sender,tokenId),"not owner nor approved"
    );
    _safeTransfer(owner, from, to, tokenId, _data);
}

function safeTransferFrom(
    address from,
    address to,
    uint tokenId
)external {
    safeTransferFrom(from,to,tokenId,"");
}

function mint(address to,uint tokenId)external {
    require(to!=address(0),"mint to zero address");
    require(_owners[tokenId]==address(0),"token already minted");
    _balances[to]+=1;
    _owners[tokenId]=to;
    emit Transfer(address(0), to, tokenId);
}

function burn(uint tokenId) external {
    address owner=ownerOf(tokenId);
    _approve(owner,address(0),tokenId);
    _balances[owner]-=1;
    delete _owners[tokenId];
    emit Transfer(owner,address(0), tokenId);
}
}