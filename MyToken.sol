// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Interface fournie
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract MyToken is IERC20 {
    
    // Infos du token
    string public name;
    string public symbol;
    uint8 public decimals;
    
    address public owner; 
    uint256 private _totalSupply;

    // Mappings requis pour l'ERC20
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    // Events pour le suivi
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "StartupCoin";
        symbol = "STC";
        decimals = 18;
        owner = msg.sender;

        // Creation initiale de 1 million de tokens
        _totalSupply = 1000000 * (10 ** uint256(decimals));

        // Le deployeur recoit tout
        balanceOf[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        // Verifs de securite
        require(recipient != address(0), "Mauvaise adresse de destination");
        require(balanceOf[msg.sender] >= amount, "Pas assez de tokens");

        // Mise a jour des soldes
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Spender invalide");

        allowance[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
MyToken.sol        require(sender != address(0), "Sender invalide");
        require(recipient != address(0), "Recipient invalide");
        
        require(balanceOf[sender] >= amount, "Solde insuffisant");
        require(allowance[sender][msg.sender] >= amount, "Allowance insuffisante");

        // On diminue l'allowance et on fait le transfert
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Fonction bonus pour creer des tokens (admin seulement)
    function mint(uint256 amount) external {
        require(msg.sender == owner, "Seul l'owner peut mint");
        require(msg.sender != address(0), "Adresse invalide");

        _totalSupply += amount;
        balanceOf[msg.sender] += amount;

        emit Transfer(address(0), msg.sender, amount);
    }

    // Fonction bonus pour bruler ses tokens
    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Solde trop bas pour burn");

        balanceOf[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }
}
