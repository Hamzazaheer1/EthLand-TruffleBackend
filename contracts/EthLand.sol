// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.2;

contract Land {
    address superAdmin;
    address physicalVerification;

    constructor() {
        superAdmin = msg.sender;
    }

    struct Admin {
        uint256 id;
        address _addr;
        string name;
        uint256 age;
        string designation;
        string city;
    }

    struct User {
        address id;
        string name;
        uint256 age;
        string city;
        string cnic;
        uint256 mobile;
        bool isUserVerified;
    }

    struct LandInfo {
        string landId;
        bool isLandVerified;
        uint256 landPrice;
        bool isforSell;
        address ownerAddress;
    }

    struct LandRequest {
        uint256 reqId;
        address sellerId;
        address buyerId;
        uint256 landId;
        reqStatus requestStatus;
        bool isPaymentDone;
    }
    enum reqStatus {
        requested,
        accepted,
        rejected,
        paymentdone,
        commpleted
    }

    uint256 adminCount;
    uint256 public userCount;

    //testing
    uint256 public landsCount;
    uint256 requestCount;

    //admin Mapping
    mapping(address => Admin) public AdminMapping; //Admin Detailed Info
    mapping(uint256 => address[]) allAdminList;
    mapping(address => bool) RegisteredAdminMapping;

    //users Mapping
    mapping(address => User) public UserMapping; //Users Detailed Info
    mapping(uint256 => address) AllUsers;
    mapping(uint256 => address[]) allUsersList;
    mapping(uint256 => address[]) allUnverifiedUsersList;
    mapping(address => bool) RegisteredUserMapping;

    //land Mapping
    mapping(uint256 => LandInfo) public LandR; //Land Detailed Info
    mapping(address => uint256[]) MyLands;
    mapping(uint256 => address) public LandOwner;
    mapping(uint256 => uint256[]) allunverifiedLandList;
    mapping(uint256 => uint256[]) allLandList;

    //land requests Mapping
    mapping(uint256 => LandRequest) public LandRequestMapping;
    mapping(address => uint256[]) MyReceivedLandRequest;
    mapping(address => uint256[]) MySentLandRequest;

    //payment Mapping
    mapping(uint256 => uint256[]) paymentDoneList;

    //APIs
    // general
    function isLogin(address _addr, uint256 _secP)
        public
        view
        returns (uint256)
    {
        if (_addr == superAdmin && _secP == 123) return 1;
        else if (_addr == superAdmin && _secP == 321) return 2;
        else if (RegisteredAdminMapping[_addr] && _secP == 456) return 4;
        else if (RegisteredAdminMapping[_addr] && _secP == 654) {
            return 5;
        } else if (RegisteredUserMapping[_addr] && _secP == 789) {
            if (!isUserVerified(_addr)) return 6;
            else return 7;
        } else return 3;
    }

    // [SuperAdmin]
    function changeSuperAdmin(address _addr) public {
        require(msg.sender == superAdmin, "you are not superAdmin");

        superAdmin = _addr;
    }

    // [SuperAdmin]
    function addPhysicalVerification(address _addr1) public {
        require(msg.sender == superAdmin, "you are not contractOwner");
        physicalVerification = _addr1;
    }

    //-----------------------------------------------Admin-----------------------------------------------

    // [SuperAdmin]
    function addAdmin(
        address _addr,
        string memory _name,
        uint256 _age,
        string memory _designation,
        string memory _city
    ) public returns (bool) {
        if (superAdmin != msg.sender) return false;
        require(superAdmin == msg.sender);
        RegisteredAdminMapping[_addr] = true;
        allAdminList[1].push(_addr);
        AdminMapping[_addr] = Admin(
            adminCount,
            _addr,
            _name,
            _age,
            _designation,
            _city
        );
        return true;
    }

    //  [SuperAdmin]
    function ReturnAllAdminList() public view returns (address[] memory) {
        return allAdminList[1];
    }

    function removeAdminAuthFailed(address _addr) public {
        require(RegisteredAdminMapping[_addr], "Admin not found");
        RegisteredAdminMapping[_addr] = false;

        uint256 len = allAdminList[1].length;
        for (uint256 i = 0; i < len; i++) {
            if (allAdminList[1][i] == _addr) {
                allAdminList[1][i] = allAdminList[1][len - 1];
                allAdminList[1].pop();
                break;
            }
        }
    }

    //  [SuperAdmin]
    function removeAdmin(address _addr) public {
        require(msg.sender == superAdmin, "You are not Super Admin");
        require(RegisteredAdminMapping[_addr], "Admin not found");
        RegisteredAdminMapping[_addr] = false;

        uint256 len = allAdminList[1].length;
        for (uint256 i = 0; i < len; i++) {
            if (allAdminList[1][i] == _addr) {
                allAdminList[1][i] = allAdminList[1][len - 1];
                allAdminList[1].pop();
                break;
            }
        }
    }

    // general
    function isAdmin(address _id) public view returns (bool) {
        if (RegisteredAdminMapping[_id]) {
            return true;
        } else {
            return false;
        }
    }

    //-----------------------------------------------User-----------------------------------------------

    // general
    function isUserRegistered(address _addr) public view returns (bool) {
        if (RegisteredUserMapping[_addr]) {
            return true;
        } else {
            return false;
        }
    }

    // [Users]
    function registerUser(
        string memory _name,
        uint256 _age,
        string memory _city,
        string memory _cnic,
        uint256 _mobile
    ) public {
        require(!RegisteredUserMapping[msg.sender]);

        RegisteredUserMapping[msg.sender] = true;
        userCount++;
        allUsersList[1].push(msg.sender);
        allUnverifiedUsersList[1].push(msg.sender);
        AllUsers[userCount] = msg.sender;
        UserMapping[msg.sender] = User(
            msg.sender,
            _name,
            _age,
            _city,
            _cnic,
            _mobile,
            false
        );
        //emit Registration(msg.sender);
    }

    // general
    function isUserVerified(address id) public view returns (bool) {
        return UserMapping[id].isUserVerified;
    }

    // [admin]
    function verifyUser(address _userId) public {
        require(isAdmin(msg.sender));
        UserMapping[_userId].isUserVerified = true;

        uint256 len = allUnverifiedUsersList[1].length;
        for (uint256 i = 0; i < len; i++) {
            if (allUnverifiedUsersList[1][i] == _userId) {
                allUnverifiedUsersList[1][i] = allUnverifiedUsersList[1][
                    len - 1
                ];
                allUnverifiedUsersList[1].pop();
                break;
            }
        }
    }

    // [admin]
    function ReturnAllUserList() public view returns (address[] memory) {
        return allUsersList[1];
    }

    // [admin]
    function removeUser(address _addr) public {
        require(isAdmin(msg.sender));
        require(RegisteredUserMapping[_addr], "User not found");
        RegisteredUserMapping[_addr] = false;

        uint256 len = allUsersList[1].length;
        for (uint256 i = 0; i < len; i++) {
            if (allUsersList[1][i] == _addr) {
                allUsersList[1][i] = allUsersList[1][len - 1];
                allUsersList[1].pop();
                break;
            }
        }
    }

    // [admin]
    function ReturnAllUrverifiedUsers() public view returns (address[] memory) {
        return allUnverifiedUsersList[1];
    }

    //-----------------------------------------------Land-----------------------------------------------

    // [admin]
    function addLand(
        string memory _landId,
        uint256 _landPrice,
        address _ownerPK,
        bool _isForSale
    ) public {
        //require(isUserVerified(msg.sender));
        landsCount++;
        LandR[landsCount] = LandInfo(
            _landId,
            true,
            _landPrice,
            _isForSale,
            _ownerPK
        );
        LandOwner[landsCount] = _ownerPK;
        MyLands[_ownerPK].push(landsCount);
        allLandList[1].push(landsCount);
        // allunverifiedLandList[1].push(landsCount);
        // emit AddingLand(landsCount);
    }

    // [admin] //return [1,2,3]
    function ReturnAllLandList() public view returns (uint256[] memory) {
        return allLandList[1];
    }

    // [User] //adress //return [1,2,3] of specific person
    function myAllLands(address id) public view returns (uint256[] memory) {
        return MyLands[id];
    }

    // [users] not implemented
    function makeItforSell(
        uint256 id,
        bool isForSale,
        uint256 price
    ) public {
        require(LandR[id].ownerAddress == msg.sender);
        LandR[id].isforSell = isForSale;
        LandR[id].landPrice = price;
    }

    // ====> Not using <==== [Admin]
    // function verifyLand(uint256 _id) public {
    //     require(isAdmin(msg.sender));
    //     LandR[_id].isLandVerified = true;

    //     uint256 len = allunverifiedLandList[1].length;
    //     for (uint256 i = 0; i < len; i++) {
    //         if (allunverifiedLandList[1][i] == _id) {
    //             allunverifiedLandList[1][i] = allunverifiedLandList[1][len - 1];
    //             allunverifiedLandList[1].pop();
    //             break;
    //         }
    //     }
    // }

    // [User+Admin]   //send landid return true/false
    // function isLandVerified(uint256 id) public view returns (bool) {
    //     return LandR[id].isLandVerified;
    // }

    // ====> Not using <====  [admin] //pass 1 // get list of unverfied lands
    // function allUnverifiedLands(uint256 id)
    //     public
    //     view
    //     returns (uint256[] memory)
    // {
    //     return allunverifiedLandList[id];
    // }

    //-----------------------------------------------Land-Requests-----------------------------------------------

    // [user] not implemented ==> working state
    function requestforBuy(uint256 _landId) public {
        //require(isUserVerified(msg.sender)); //temp commented it
        requestCount++;
        LandRequestMapping[requestCount] = LandRequest(
            requestCount,
            LandR[_landId].ownerAddress,
            msg.sender,
            _landId,
            reqStatus.requested,
            false
        );
        MyReceivedLandRequest[LandR[_landId].ownerAddress].push(requestCount);
        MySentLandRequest[msg.sender].push(requestCount);
    }

    // [user] not implemented //working
    function myReceivedLandRequests() public view returns (uint256[] memory) {
        return MyReceivedLandRequest[msg.sender];
    }

    // [user] not implemented
    function mySentLandRequests() public view returns (uint256[] memory) {
        return MySentLandRequest[msg.sender];
    }

    // [user] not implemented //working
    function acceptRequest(uint256 _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = reqStatus.accepted;
    }

    // [user] not implemented
    function rejectRequest(uint256 _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = reqStatus.rejected;
    }

    // [user] not implemented
    function requesteStatus(uint256 id) public view returns (bool) {
        return LandRequestMapping[id].isPaymentDone;
    }

    //-----------------------------------------------Land-Payments-----------------------------------------------

    // [user] not implemented
    function landPrice(uint256 id) public view returns (uint256) {
        return LandR[id].landPrice;
    }

    // [user] not implemented
    function makePayment(uint256 _requestId) public payable {
        require(
            LandRequestMapping[_requestId].buyerId == msg.sender &&
                LandRequestMapping[_requestId].requestStatus ==
                reqStatus.accepted
        );

        LandRequestMapping[_requestId].requestStatus = reqStatus.paymentdone;
        //LandRequestMapping[_requestId].sellerId.transfer(lands[LandRequestMapping[_requestId].landId].landPrice);
        //lands[LandRequestMapping[_requestId].landId].ownerAddress.transfer(lands[LandRequestMapping[_requestId].landId].landPrice);
        address payable sellerAddr = payable(
            LandR[LandRequestMapping[_requestId].landId].ownerAddress
        );
        sellerAddr.transfer(msg.value);
        LandRequestMapping[_requestId].isPaymentDone = true;
        paymentDoneList[1].push(_requestId);
    }

    // [user] not implemented
    function returnPaymentDoneList() public view returns (uint256[] memory) {
        return paymentDoneList[1];
    }

    // [user] not implemented
    function makePaymentTestFun(address payable _reveiver) public payable {
        _reveiver.transfer(msg.value);
    }

    //-----------------------------------------------Land-Ownership-----------------------------------------------
    // [Admin] not implemented
    function transferOwnership(uint256 _requestId) public returns (bool) {
        //require(isAdmin(msg.sender)); //temp
        if (LandRequestMapping[_requestId].isPaymentDone == false) return false;

        LandRequestMapping[_requestId].requestStatus = reqStatus.commpleted;
        MyLands[LandRequestMapping[_requestId].buyerId].push(
            LandRequestMapping[_requestId].landId
        );

        uint256 len = MyLands[LandRequestMapping[_requestId].sellerId].length;
        for (uint256 i = 0; i < len; i++) {
            if (
                MyLands[LandRequestMapping[_requestId].sellerId][i] ==
                LandRequestMapping[_requestId].landId
            ) {
                MyLands[LandRequestMapping[_requestId].sellerId][i] = MyLands[
                    LandRequestMapping[_requestId].sellerId
                ][len - 1];
                //MyLands[LandRequestMapping[_requestId].sellerId].length--;
                MyLands[LandRequestMapping[_requestId].sellerId].pop();
                break;
            }
        }
        LandR[LandRequestMapping[_requestId].landId].isforSell = false;
        LandR[LandRequestMapping[_requestId].landId]
            .ownerAddress = LandRequestMapping[_requestId].buyerId;
        return true;
    }
}
