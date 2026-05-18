enum Role {
  owner,
  manager,
  receptionist,
  mechanic,
  accountant,
  managerSales,
  managerWarehouse,
  hrManager,
}

extension RoleExtension on Role {
  static Role fromString(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return Role.owner;
      case 'manager':
        return Role.manager;
      case 'receptionist':
        return Role.receptionist;
      case 'mechanic':
        return Role.mechanic;
      case 'accountant':
        return Role.accountant;
      case 'manager_sales':
        return Role.managerSales;
      case 'manager_warehouse':
        return Role.managerWarehouse;
      case 'hr_manager':
        return Role.hrManager;
      default:
        return Role.owner;
    }
  }

  String get value {
    switch (this) {
      case Role.owner:
        return 'OWNER';
      case Role.manager:
        return 'MANAGER';
      case Role.receptionist:
        return 'RECEPTIONIST';
      case Role.mechanic:
        return 'MECHANIC';
      case Role.accountant:
        return 'ACCOUNTANT';
      case Role.managerSales:
        return 'MANAGER_SALES';
      case Role.managerWarehouse:
        return 'MANAGER_WAREHOUSE';
      case Role.hrManager:
        return 'HR_MANAGER';
    }
  }
}
