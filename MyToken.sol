// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract MyToken is IERC20 {
    // Infos publiques du token
    string public name;
    string public symbol;
    uint8 public decimals;

    // Total supply stocké en privé 
    uint256 private _totalSupply;

    // Mapping pour les soldes de chaque adresse
    mapping(address => uint256) public balanceOf;
    // Mapping pour gérer les permissions (Owner => Spender => Montant)
    mapping(address => mapping(address => uint256)) public allowance;

    // L'adresse de l'administrateur du contrat
    address public owner;

    // Événements pour la traçabilité sur la blockchain
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Modifier pour restreindre l'accès à certaines fonctions
    modifier onlyOwner() {
        require(msg.sender == owner, "MyToken: caller is not the owner");
        _;
    }

    constructor() {
        // Initialisation des métadonnées
        name = "MyToken";
        symbol = "MTK";
        decimals = 18;

        // Le déployeur devient le propriétaire
        owner = msg.sender;

        // Création de 1 million de tokens (ajusté avec les décimales)
        uint256 initialSupply = 1_000_000 * (10 ** uint256(decimals));
        _totalSupply = initialSupply;

        // On attribue la totalité des tokens au déployeur
        balanceOf[msg.sender] = initialSupply;

        // On émet l'event de création (depuis l'adresse 0)
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // ==== Fonctions de l'interface IERC20 ====

    // Retourne la quantité totale de tokens en circulation
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Fonction de transfert simple
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        // On utilise la fonction interne pour éviter de dupliquer la logique
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Autorise une adresse (spender) à dépenser un certain montant
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "MyToken: approve to the zero address");

        // Enregistrement de l'autorisation
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    // Transfert délégué (ex: un échange décentralisé récupère vos tokens)
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        // Vérification de l'autorisation
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "MyToken: transfer amount exceeds allowance");

        // Exécution du transfert
        _transfer(sender, recipient, amount);

        // Mise à jour de l'allowance restante (on soustrait ce qui a été envoyé)
        allowance[sender][msg.sender] = currentAllowance - amount;
        emit Approval(sender, msg.sender, allowance[sender][msg.sender]);

        return true;
    }

    // ==== Bonus : mint & burn ====

    // Création de nouveaux tokens (réservé à l'owner)
    function mint(uint256 amount) external onlyOwner {
        require(owner != address(0), "MyToken: owner is the zero address");

        // Augmente le total et le solde du propriétaire
        _totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount);
    }

    // Destruction de tokens (accessible à tous)
    function burn(uint256 amount) external {
        uint256 accountBalance = balanceOf[msg.sender];
        require(accountBalance >= amount, "MyToken: burn amount exceeds balance");

        // Réduit le solde et le total supply
        balanceOf[msg.sender] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    // ==== Fonction interne (Helper) ====

    // Logique centrale de transfert pour éviter la répétition de code
    function _transfer(address sender, address recipient, uint256 amount) internal {
        // Vérifications de sécurité de base
        require(sender != address(0), "MyToken: transfer from the zero address");
        require(recipient != address(0), "MyToken: transfer to the zero address");

        // Vérification du solde de l'expéditeur
        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "MyToken: transfer amount exceeds balance");

        // Mise à jour des soldes
        balanceOf[sender] = senderBalance - amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}
