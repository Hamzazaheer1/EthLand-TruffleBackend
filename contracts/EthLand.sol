// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.2;

contract Land {
    address superAdmin;
    address physicalVerification;

    constructor() {
        superAdmin = msg.sender;
    }

    struct Admin {
        uint id;
        address _addr;
        string name;
        uint age;
        string designation;
        string city;
    }

     struct User{
        address id;
        string name;
        uint age;
        string city;
        string cnic;
        uint mobile;
        bool isUserVerified;
    }

    uint adminCount;
    uint public userCount;

    mapping(address => Admin) public AdminMapping;
    mapping(uint => address[]) allAdminList;
    mapping(address => bool)  RegisteredAdminMapping;

    mapping(address => User) public UserMapping;
    mapping(uint => address)  AllUsers;
    mapping(uint => address[])  allUsersList;
    mapping(address => bool)  RegisteredUserMapping;

// general
    function isLogin(address _addr, uint _secP) public view returns(uint){
        if(_addr==superAdmin && _secP == 123)
            return 1;
        else if(_addr == superAdmin && _secP == 321)
            return 2;
        else if(RegisteredAdminMapping[_addr] && _secP == 456)
            return 4;
        else if(RegisteredAdminMapping[_addr] && _secP == 654){
            return 5;
        }else if(RegisteredUserMapping[_addr] && _secP == 789) {
            if(!isUserVerified(_addr))
                return 6;
            else
                return 7;
        }
        else
            return 3;
    }

// [SuperAdmin]
    function changeSuperAdmin(address _addr)public {
        require(msg.sender==superAdmin,"you are not superAdmin");

        superAdmin=_addr;
    }

// [SuperAdmin]
    function addPhysicalVerification(address _addr1) public {
       require(msg.sender==superAdmin,"you are not contractOwner");
        physicalVerification = _addr1;
    }

    //-----------------------------------------------Admin-----------------------------------------------

// [SuperAdmin]
    function addAdmin(address _addr,string memory _name, uint _age, string memory _designation,string memory _city) public returns(bool){
        if(superAdmin!=msg.sender)
            return false;
        require(superAdmin==msg.sender);
        RegisteredAdminMapping[_addr]=true;
        allAdminList[1].push(_addr);
        AdminMapping[_addr] = Admin(adminCount,_addr,_name, _age, _designation,_city);
        return true;
    }

//  [SuperAdmin]
    function ReturnAllAdminList() public view returns(address[] memory){
        return allAdminList[1];
    }

    function removeAdminAuthFailed(address _addr) public{
        require(RegisteredAdminMapping[_addr],"Admin not found");
        RegisteredAdminMapping[_addr]=false;


        uint len=allAdminList[1].length;
        for(uint i=0;i<len;i++)
        {
            if(allAdminList[1][i]==_addr)
            {
                allAdminList[1][i]=allAdminList[1][len-1];
                allAdminList[1].pop();
                break;
            }
        }
    }
 
//  [SuperAdmin]
    function removeAdmin(address _addr) public{
        require(msg.sender==superAdmin,"You are not Super Admin");
        require(RegisteredAdminMapping[_addr],"Admin not found");
        RegisteredAdminMapping[_addr]=false;


        uint len=allAdminList[1].length;
        for(uint i=0;i<len;i++)
        {
            if(allAdminList[1][i]==_addr)
            {
                allAdminList[1][i]=allAdminList[1][len-1];
                allAdminList[1].pop();
                break;
            }
        }
    }

// general
    function isAdmin(address _id) public view returns (bool) {
        if(RegisteredAdminMapping[_id]){
            return true;
        }else{
            return false;
        }
    }

    //-----------------------------------------------User-----------------------------------------------

// general
    function isUserRegistered(address _addr) public view returns(bool){
        if(RegisteredUserMapping[_addr]){
            return true;
        }else{
            return false;
        }
    }

// [Users]
    function registerUser(string memory _name, uint _age, string memory _city, string memory _cnic, uint _mobile
    ) public {

        require(!RegisteredUserMapping[msg.sender]);

        RegisteredUserMapping[msg.sender] = true;
        userCount++;
        allUsersList[1].push(msg.sender);
        AllUsers[userCount]=msg.sender;
        UserMapping[msg.sender] = User(msg.sender, _name, _age, _city, _cnic, _mobile, false);
        //emit Registration(msg.sender);
    }
    
// general
    function isUserVerified(address id) public view returns(bool){
        return UserMapping[id].isUserVerified;
    }


// [admin]
    function verifyUser(address _userId) public{
        require(isAdmin(msg.sender));
        UserMapping[_userId].isUserVerified=true;
    }

// [admin]   
    function ReturnAllUserList() public view returns(address[] memory){
        return allUsersList[1];
    }

// [admin]  
    function removeUser(address _addr) public{
        require(isAdmin(msg.sender));
        require(RegisteredUserMapping[_addr],"User not found");
        RegisteredUserMapping[_addr]=false;


        uint len=allUsersList[1].length;
        for(uint i=0;i<len;i++)
        {
            if(allUsersList[1][i]==_addr)
            {
                allUsersList[1][i]=allUsersList[1][len-1];
                allUsersList[1].pop();
                break;
            }
        }
    }
}