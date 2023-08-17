public with sharing class WarehouseStructure {
    private Integer width;
    private Integer height;
    private Integer length;

    // private Integer maxCellLevel;
    // private List<Warehouse_Cell__c> cellList;
    // private Map<Id, Container__c> cellIdToContainerMap;
    // private List<List<List<Warehouse_Cell__c>>> warehouseMatrix;
 
    public ContainerWarehouseStructure(Warehouse__c warehouse) {
        this.width = Integer.valueOf(warehouse.Width_Containers__c);
        this.height = Integer.valueOf(warehouse.Height_Containers__c);
        this.length = Integer.valueOf(warehouse.Length_Containers__c);

        // this.maxCellLevel = Integer.valueOf(warehouse.Max_Cell_Level__c);
        // this.cellList = obtainCellList(warehouse.Id);
        // this.cellIdToContainerMap = createCellIdToContainerMap();
        // this.warehouseMatrix = createWarehouseMatrix();
    }

    public Integer getWidth() {
        return this.width;
    }

    public Integer getHeight() {
        return this.height;
    }

    public Integer getLength() {
        return this.length;
    }

    // public Integer getMaxCellLevel() {
    //     return this.maxCellLevel;
    // }

    // public List<List<List<Warehouse_Cell__c>>> getWarehouseMatrix() {
    //     return this.warehouseMatrix;
    // }

    // public List<Warehouse_Cell__c> getCellList() {
    //     return this.cellList;
    // }

    // public Map<Id, Container__c> getCellIdToContainerMap() {
    //     return this.cellIdToContainerMap;
    // }

    private List<Warehouse_Cell__c> obtainCellListByWarehouseId(String warehouseId) {
        return [
            SELECT Unique_Address__c, Level__c, Is_Free__c, (SELECT Id, Issuance_Date__c, Status__c FROM Containers__r LIMIT 1) 
            FROM Warehouse_Cell__c
            WHERE Warehouse__c = :warehouseId
        ];
    }

    private Map<Id, Container__c> createCellIdToContainerMap() {
        Map<Id, Container__c> cellIdToContainerMap = new Map<Id, Container__c>();
        for (Warehouse_Cell__c cell : this.cellList) {
            if (cell.Containers__r.isEmpty()) {
                cellIdToContainerMap.put(cell.Id, null);
            } else {
                cellIdToContainerMap.put(cell.Id, cell.Containers__r[0]);
            }
        }
        return cellIdToContainerMap;
    }

    private List<List<List<Warehouse_Cell__c>>> createWarehouseMatrix() {
        List<List<List<Warehouse_Cell__c>>> matrix = new List<List<List<Warehouse_Cell__c>>>();

        for (Integer i = 0; i < width; i++) {
            List<List<Warehouse_Cell__c>> column = new List<List<Warehouse_Cell__c>>();
            for (Integer j = 0; j < length; j++) {
                List<Warehouse_Cell__c> row = new List<Warehouse_Cell__c>();
                for (Integer k = 0; k < maxCellLevel; k++) {
                    Warehouse_Cell__c cell = findCell(k + 1, i + 1, j + 1);
                    row.add(cell);
                }
                column.add(row);
            }
            matrix.add(column);
        }
        return matrix;
    }
    
    private Warehouse_Cell__c findCell(Integer level, Integer widthOffset, Integer column) {
        for (Warehouse_Cell__c cell : cellList) {
            Integer cellLevel = Integer.valueOf(cell.Level__c);
            Integer cellWidthOffset = convertLetterToNumber(cell.Address__c.substring(0, 1));
            Integer cellColumn = Integer.valueOf(cell.Address__c.substring(1, 2));
            
            if (cellLevel == level && cellWidthOffset == widthOffset && cellColumn == column) {
                return cell;
            }
        }
        return null;
    }

    private Integer convertLetterToNumber(String letter) {
        String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer num = 0;
        for (Integer i = 0; i < letter.length(); i++) {
            Integer charIndex = alphabet.indexOf(letter.toUpperCase().substring(i, i+1)) + 1;
            num = (num * 26) + charIndex;
        }
        return num;
    }

}