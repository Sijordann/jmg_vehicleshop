// Global Variables
let currentVehicles = [];
let currentCategories = {};
let playerMoney = 0;
let selectedVehicle = null;
let shopData = null;
let currentStockVehicle = null;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
});

// Setup Event Listeners
function setupEventListeners() {
    // Search functionality
    document.getElementById('searchInput').addEventListener('input', function() {
        filterVehicles();
    });
    
    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });
    
    // Plate input formatting
    document.getElementById('plateInput').addEventListener('input', function() {
        this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '').substring(0, 8);
    });
    
    // Close modals on outside click
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal')) {
            closeModal();
            closeStockModal();
        }
    });
    
    // Escape key to close and disable dev tools
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeMenu();
            closeModal();
            closeStockModal();
        }
        
        // Disable dev tools
        if (e.key === 'F12' || 
            (e.ctrlKey && e.shiftKey && e.key === 'I') ||
            (e.ctrlKey && e.shiftKey && e.key === 'C') ||
            (e.ctrlKey && e.shiftKey && e.key === 'J') ||
            (e.ctrlKey && e.key === 'U')) {
            e.preventDefault();
        }
    });
}

// NUI Message Handler
let lastCloseTime = 0;

window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('NUI message received:', data);

    switch(data.type) {
        case 'openShop':
            openShopMenu(data);
            break;
        case 'openBoss':
            openBossMenu(data);
            break;
        case 'closeMenu':
            const now = Date.now();
            if (now - lastCloseTime > 1000) { // Minimal 1 detik antar close
                closeMenu();
                lastCloseTime = now;
            }
            break;
    }
});

// Shop Menu Functions
function openShopMenu(data) {
    currentVehicles = data.vehicles || [];
    currentCategories = data.categories || {};
    playerMoney = data.playerMoney || 0;
    
    document.getElementById('playerMoney').textContent = formatMoney(playerMoney);
    
    populateCategories();
    populateVehicles();
    
    document.getElementById('shopMenu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function openBossMenu(data) {
    shopData = data.shopData;
    
    if (!shopData) {
        showNotification('Failed to load shop data', 'error');
        return;
    }
    
    populateStockGrid();
    populateSalesHistory();
    updateSocietyBalance();
    loadTransactions();
    loadEmployees();
    
    document.getElementById('bossMenu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeMenu() {
    document.getElementById('shopMenu').style.display = 'none';
    document.getElementById('bossMenu').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Send close message to Lua
    fetch('https://vehicleshop/closeMenu', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Categories
function populateCategories() {
    const grid = document.getElementById('categoriesGrid');
    grid.innerHTML = '';
    
    // Add "All" category
    const allBtn = document.createElement('button');
    allBtn.className = 'category-btn active';
    allBtn.dataset.category = 'all';
    allBtn.innerHTML = '<i class="fas fa-th"></i> All';
    allBtn.addEventListener('click', () => selectCategory('all'));
    grid.appendChild(allBtn);
    
    // Add other categories
    const categoryIcons = {
        'compacts': 'fas fa-car',
        'sedans': 'fas fa-car-side',
        'suvs': 'fas fa-truck',
        'coupes': 'fas fa-car',
        'muscle': 'fas fa-car',
        'sports': 'fas fa-racing-car',
        'super': 'fas fa-rocket',
        'motorcycles': 'fas fa-motorcycle',
        'offroad': 'fas fa-truck-monster',
        'industrial': 'fas fa-truck',
        'utility': 'fas fa-truck',
        'vans': 'fas fa-shuttle-van',
        'cycles': 'fas fa-bicycle',
        'boats': 'fas fa-ship',
        'helicopters': 'fas fa-helicopter',
        'planes': 'fas fa-plane'
    };
    
    Object.keys(currentCategories).forEach(category => {
        const btn = document.createElement('button');
        btn.className = 'category-btn';
        btn.dataset.category = category;
        btn.innerHTML = `<i class="${categoryIcons[category] || 'fas fa-car'}"></i> ${currentCategories[category]}`;
        btn.addEventListener('click', () => selectCategory(category));
        grid.appendChild(btn);
    });
}

function selectCategory(category) {
    // Update active button
    document.querySelectorAll('.category-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-category="${category}"]`).classList.add('active');
    
    // Filter vehicles
    filterVehicles();
}

// Vehicles
function populateVehicles() {
    const grid = document.getElementById('vehiclesGrid');
    grid.innerHTML = '';
    
    const filteredVehicles = getFilteredVehicles();
    
    if (filteredVehicles.length === 0) {
        grid.innerHTML = '<div class="no-results">No vehicles found</div>';
        return;
    }
    
    filteredVehicles.forEach(vehicle => {
        const card = createVehicleCard(vehicle);
        grid.appendChild(card);
    });
}

function createVehicleCard(vehicle) {
    const card = document.createElement('div');
    card.className = 'vehicle-card';
    card.addEventListener('click', () => openVehicleModal(vehicle));
    
    const stockClass = vehicle.stock > 5 ? '' : vehicle.stock > 0 ? 'low' : 'out';
    const stockText = vehicle.stock > 0 ? `${vehicle.stock} in stock` : 'Out of stock';
    
    card.innerHTML = `
        <h4>${vehicle.name}</h4>
        <div class="vehicle-info">
            <span class="vehicle-price">${formatMoney(vehicle.price)}</span>
            <span class="vehicle-category">${currentCategories[vehicle.category] || vehicle.category}</span>
        </div>
        <div class="vehicle-stock">
            <span class="stock-indicator ${stockClass}"></span>
            <span>${stockText}</span>
        </div>
    `;
    
    if (vehicle.stock === 0) {
        card.style.opacity = '0.6';
        card.style.pointerEvents = 'none';
    }
    
    return card;
}

function getFilteredVehicles() {
    const activeCategory = document.querySelector('.category-btn.active').dataset.category;
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    
    return currentVehicles.filter(vehicle => {
        const matchesCategory = activeCategory === 'all' || vehicle.category === activeCategory;
        const matchesSearch = vehicle.name.toLowerCase().includes(searchTerm) || 
                            vehicle.model.toLowerCase().includes(searchTerm);
        
        return matchesCategory && matchesSearch;
    });
}

function filterVehicles() {
    populateVehicles();
}

// Vehicle Modal
function openVehicleModal(vehicle) {
    selectedVehicle = vehicle;
    
    document.getElementById('modalVehicleName').textContent = vehicle.name;
    document.getElementById('modalVehiclePrice').textContent = formatMoney(vehicle.price);
    document.getElementById('modalVehicleCategory').textContent = currentCategories[vehicle.category] || vehicle.category;
    document.getElementById('modalVehicleStock').textContent = vehicle.stock;
    
    // Generate random plate
    document.getElementById('plateInput').value = generateRandomPlate();
    
    document.getElementById('vehicleModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('vehicleModal').style.display = 'none';
    selectedVehicle = null;
}

function buyVehicle() {
    if (!selectedVehicle) return;
    
    const plate = document.getElementById('plateInput').value.trim();
    
    if (!plate || plate.length < 2) {
        showNotification('Please enter a valid license plate', 'error');
        return;
    }
    
    if (playerMoney < selectedVehicle.price) {
        showNotification('Not enough money!', 'error');
        return;
    }
    
    showLoading(true);
    
    fetch('https://vehicleshop/buyVehicle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: selectedVehicle.model,
            plate: plate
        })
    }).then(() => {
        showLoading(false);
        closeModal();
    }).catch(() => {
        showLoading(false);
        showNotification('Purchase failed!', 'error');
    });
}

function testDriveVehicle() {
    if (!selectedVehicle) return;
    
    fetch('https://vehicleshop/testDrive', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: selectedVehicle.model
        })
    }).then(() => {
        closeModal();
    });
}

// Boss Menu Functions
function switchTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}Tab`).classList.add('active');
}

function populateStockGrid() {
    const grid = document.getElementById('stockGrid');
    grid.innerHTML = '';
    
    if (!shopData || !shopData.stock) {
        grid.innerHTML = '<div class="no-results">No stock data available</div>';
        return;
    }
    
    shopData.stock.forEach(item => {
        const stockItem = createStockItem(item);
        grid.appendChild(stockItem);
    });
}

function createStockItem(item) {
    const div = document.createElement('div');
    div.className = 'stock-item';
    
    const currentPrice = item.customPrice || item.basePrice;
    
    div.innerHTML = `
        <h4>${item.name}</h4>
        <div class="stock-details">
            <span>Base Price: ${formatMoney(item.basePrice)}</span>
            <span>Current Price: ${formatMoney(currentPrice)}</span>
            <span>Stock: ${item.stock}</span>
            <span>Category: ${item.category}</span>
        </div>
        <div class="stock-actions">
            <button class="btn btn-small btn-primary" onclick="openStockModal('${item.model}', '${item.name}')">
                <i class="fas fa-edit"></i> Manage
            </button>
        </div>
    `;
    
    return div;
}

function populateSalesHistory() {
    const list = document.getElementById('salesList');
    list.innerHTML = '';
    
    if (!shopData || !shopData.sales || shopData.sales.length === 0) {
        list.innerHTML = '<div class="no-results">No sales history available</div>';
        return;
    }
    
    shopData.sales.forEach(sale => {
        const saleItem = createSaleItem(sale);
        list.appendChild(saleItem);
    });
}

function createSaleItem(sale) {
    const div = document.createElement('div');
    div.className = 'sale-item';
    
    const date = new Date(sale.sale_date).toLocaleDateString();
    
    div.innerHTML = `
        <div class="sale-info">
            <h4>${sale.vehicle_model}</h4>
            <p>Buyer: ${sale.buyer_name} | Plate: ${sale.vehicle_plate}</p>
        </div>
        <div class="sale-price">${formatMoney(sale.sale_price)}</div>
        <div class="sale-date">${date}</div>
    `;
    
    return div;
}

// Stock Management Modal
function openStockModal(vehicleModel, vehicleName) {
    currentStockVehicle = vehicleModel;
    document.getElementById('stockModalVehicleName').textContent = `Manage ${vehicleName}`;
    document.getElementById('stockModal').style.display = 'flex';
}

function closeStockModal() {
    document.getElementById('stockModal').style.display = 'none';
    currentStockVehicle = null;
    
    // Clear inputs
    document.getElementById('addStockAmount').value = '1';
    document.getElementById('removeStockAmount').value = '1';
    document.getElementById('customPrice').value = '';
}

function addStock() {
    if (!currentStockVehicle) return;
    
    const amount = parseInt(document.getElementById('addStockAmount').value) || 1;
    
    if (amount < 1) {
        showNotification('Invalid amount', 'error');
        return;
    }
    
    fetch('https://vehicleshop/addStock', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: currentStockVehicle,
            amount: amount
        })
    }).then(() => {
        closeStockModal();
        // Refresh shop data
        setTimeout(() => {
            location.reload();
        }, 1000);
    });
}

function removeStock() {
    if (!currentStockVehicle) return;
    
    const amount = parseInt(document.getElementById('removeStockAmount').value) || 1;
    
    if (amount < 1) {
        showNotification('Invalid amount', 'error');
        return;
    }
    
    fetch('https://vehicleshop/removeStock', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: currentStockVehicle,
            amount: amount
        })
    }).then(() => {
        closeStockModal();
        // Refresh shop data
        setTimeout(() => {
            location.reload();
        }, 1000);
    });
}

function setCustomPrice() {
    if (!currentStockVehicle) return;
    
    const price = parseInt(document.getElementById('customPrice').value) || 0;
    
    if (price < 0) {
        showNotification('Invalid price', 'error');
        return;
    }
    
    fetch('https://vehicleshop/setPrice', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: currentStockVehicle,
            price: price
        })
    }).then(() => {
        closeStockModal();
        // Refresh shop data
        setTimeout(() => {
            location.reload();
        }, 1000);
    });
}

function transferOwnership() {
    const playerId = parseInt(document.getElementById('transferPlayerId').value);
    
    if (!playerId || playerId < 1) {
        showNotification('Please enter a valid player ID', 'error');
        return;
    }
    
    if (!confirm('Are you sure you want to transfer ownership? This action cannot be undone.')) {
        return;
    }
    
    fetch('https://vehicleshop/transferOwnership', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: playerId
        })
    }).then(() => {
        showNotification('Ownership transferred successfully!', 'success');
        setTimeout(() => {
            closeMenu();
        }, 2000);
    });
}

// Utility Functions
function formatMoney(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

function generateRandomPlate() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    
    // Generate format: ABC123
    for (let i = 0; i < 3; i++) {
        result += chars.charAt(Math.floor(Math.random() * 26)); // Letters only
    }
    for (let i = 0; i < 3; i++) {
        result += chars.charAt(Math.floor(Math.random() * 10) + 26); // Numbers only
    }
    
    return result;
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Style the notification
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#ef4444' : type === 'success' ? '#10b981' : '#4f46e5'};
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        z-index: 10000;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
        word-wrap: break-word;
    `;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

function showLoading(show) {
    document.getElementById('loadingOverlay').style.display = show ? 'flex' : 'none';
}

// Add CSS animations for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .no-results {
        text-align: center;
        color: rgba(255, 255, 255, 0.6);
        font-style: italic;
        padding: 40px;
        grid-column: 1 / -1;
    }
`;
document.head.appendChild(style);

// Prevent context menu
document.addEventListener('contextmenu', function(e) {
    e.preventDefault();
});

// Prevent F12 and other dev tools shortcuts


// Society Money Functions
function updateSocietyBalance() {
    if (shopData && shopData.societyMoney !== undefined) {
        document.getElementById('societyBalance').textContent = formatMoney(shopData.societyMoney);
    } else {
        // Fallback to fetch from server
        fetch(`https://${getResourceName()}/getSocietyMoney`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({})
        })
        .then(response => response.json())
        .then(money => {
            document.getElementById('societyBalance').textContent = formatMoney(money);
        })
        .catch(error => {
            console.error('Error fetching society money:', error);
            document.getElementById('societyBalance').textContent = '$0';
        });
    }
}

function depositMoney() {
    const amount = parseInt(document.getElementById('depositAmount').value);
    
    if (!amount || amount < 500 || amount > 50000) {
        showNotification('Invalid amount! Min: $500, Max: $50,000', 'error');
        return;
    }
    
    fetch(`https://${getResourceName()}/depositMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ amount: amount })
    })
    .then(response => response.json())
    .then(result => {
        if (result === 'ok') {
            document.getElementById('depositAmount').value = '';
            showNotification('Money deposited successfully!', 'success');
            // Refresh data
            setTimeout(() => {
                updateSocietyBalance();
                loadTransactions();
            }, 1000);
        }
    })
    .catch(error => {
        console.error('Error depositing money:', error);
        showNotification('Failed to deposit money', 'error');
    });
}

function withdrawMoney() {
    const amount = parseInt(document.getElementById('withdrawAmount').value);
    
    if (!amount || amount < 1000 || amount > 100000) {
        showNotification('Invalid amount! Min: $1,000, Max: $100,000', 'error');
        return;
    }
    
    fetch(`https://${getResourceName()}/withdrawMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ amount: amount })
    })
    .then(response => response.json())
    .then(result => {
        if (result === 'ok') {
            document.getElementById('withdrawAmount').value = '';
            showNotification('Money withdrawn successfully!', 'success');
            // Refresh data
            setTimeout(() => {
                updateSocietyBalance();
                loadTransactions();
            }, 1000);
        }
    })
    .catch(error => {
        console.error('Error withdrawing money:', error);
        showNotification('Failed to withdraw money', 'error');
    });
}

function loadTransactions() {
    fetch(`https://${getResourceName()}/getTransactions`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(transactions => {
        populateTransactions(transactions);
    })
    .catch(error => {
        console.error('Error loading transactions:', error);
        document.getElementById('transactionsList').innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.6);">Failed to load transactions</p>';
    });
}

function populateTransactions(transactions) {
    const container = document.getElementById('transactionsList');
    
    if (!transactions || transactions.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.6);">No transactions found</p>';
        return;
    }
    
    container.innerHTML = '';
    
    transactions.forEach(transaction => {
        const item = createTransactionItem(transaction);
        container.appendChild(item);
    });
}

function createTransactionItem(transaction) {
    const item = document.createElement('div');
    item.className = 'transaction-item';
    
    const isPositive = transaction.transaction_type === 'deposit' || transaction.transaction_type === 'sale';
    const amountClass = isPositive ? 'positive' : 'negative';
    const amountPrefix = isPositive ? '+' : '-';
    
    const date = new Date(transaction.transaction_date);
    const formattedDate = date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    
    item.innerHTML = `
        <div class="transaction-info">
            <div class="transaction-type ${transaction.transaction_type}">
                ${getTransactionTypeIcon(transaction.transaction_type)} ${getTransactionTypeName(transaction.transaction_type)}
            </div>
            <div class="transaction-description">${transaction.description || 'No description'}</div>
            <div class="transaction-date">${formattedDate}</div>
        </div>
        <div class="transaction-amount ${amountClass}">
            ${amountPrefix}${formatMoney(transaction.amount)}
        </div>
    `;
    
    return item;
}

function getTransactionTypeIcon(type) {
    switch(type) {
        case 'deposit': return '<i class="fas fa-arrow-down"></i>';
        case 'withdraw': return '<i class="fas fa-arrow-up"></i>';
        case 'commission': return '<i class="fas fa-percentage"></i>';
        case 'sale': return '<i class="fas fa-shopping-cart"></i>';
        default: return '<i class="fas fa-question"></i>';
    }
}

function getTransactionTypeName(type) {
    switch(type) {
        case 'deposit': return 'Deposit';
        case 'withdraw': return 'Withdrawal';
        case 'commission': return 'Commission';
        case 'sale': return 'Vehicle Sale';
        default: return 'Unknown';
    }
}

// Helper function to get resource name
function getResourceName() {
    return window.GetParentResourceName && typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'vehicleshop';
}

// Employee Management Functions
function recruitEmployee() {
    const playerId = document.getElementById('recruitPlayerId').value;
    const playerName = document.getElementById('recruitPlayerName').value || '';
    
    if (!playerId || playerId < 1) {
        showNotification('Please enter a valid Player ID', 'error');
        return;
    }
    
    showLoading(true);
    
    fetch(`https://${getResourceName()}/recruitEmployee`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            playerId: parseInt(playerId),
            playerName: playerName
        })
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        if (data.success) {
            showNotification(data.message || 'Employee recruited successfully!', 'success');
            document.getElementById('recruitPlayerId').value = '';
            document.getElementById('recruitPlayerName').value = '';
            loadEmployees();
        } else {
            showNotification(data.message || 'Failed to recruit employee', 'error');
        }
    })
    .catch(error => {
        showLoading(false);
        console.error('Error recruiting employee:', error);
        showNotification('Error recruiting employee', 'error');
    });
}

function fireEmployee(playerId) {
    if (!confirm('Are you sure you want to fire this employee?')) {
        return;
    }
    
    showLoading(true);
    
    fetch(`https://${getResourceName()}/fireEmployee`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            playerId: playerId
        })
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        if (data.success) {
            showNotification(data.message || 'Employee fired successfully!', 'success');
            loadEmployees();
        } else {
            showNotification(data.message || 'Failed to fire employee', 'error');
        }
    })
    .catch(error => {
        showLoading(false);
        console.error('Error firing employee:', error);
        showNotification('Error firing employee', 'error');
    });
}

function loadEmployees() {
    fetch(`https://${getResourceName()}/getEmployees`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            populateEmployees(data.employees || []);
        } else {
            console.error('Failed to load employees:', data.message);
        }
    })
    .catch(error => {
        console.error('Error loading employees:', error);
    });
}

function populateEmployees(employees) {
    const employeesList = document.getElementById('employeesList');
    
    if (!employees || employees.length === 0) {
        employeesList.innerHTML = `
            <div class="empty-employees">
                <i class="fas fa-users"></i>
                <p>No employees recruited yet</p>
                <small>Recruit players to help manage your vehicle shop</small>
            </div>
        `;
        return;
    }
    
    employeesList.innerHTML = employees.map(employee => createEmployeeItem(employee)).join('');
}

function createEmployeeItem(employee) {
    const recruitedDate = new Date(employee.recruited_at).toLocaleDateString();
    
    return `
        <div class="employee-item">
            <div class="employee-info">
                <div class="employee-name">${employee.name || 'Unknown Player'}</div>
                <div class="employee-id">ID: ${employee.player_id} • Recruited: ${recruitedDate}</div>
            </div>
            <div class="employee-actions">
                <button class="btn-fire" onclick="fireEmployee(${employee.player_id})">
                    <i class="fas fa-user-times"></i>
                    Fire
                </button>
            </div>
        </div>
    `;
}