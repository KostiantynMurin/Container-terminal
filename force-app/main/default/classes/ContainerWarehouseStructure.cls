/**
 * @description  ContainerWarehouseStructure class.
 * @author Kostiantyn Murin
 * @date 07-07-2023
 */
public with sharing class ContainerWarehouseStructure {
    private Integer width;
    private Integer length;
    private Integer maxCellLevel;
    private List<Warehouse_Cell__c> cellList;
    private Map<Id, Container__c> cellIdToContainerMap;
    private List<List<List<Warehouse_Cell__c>>> warehouseMatrix;
 
    /**
     * @description  Constructor.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public ContainerWarehouseStructure(Container_Warehouse__c warehouse) {
        this.width = Integer.valueOf(warehouse.Width__c);
        this.length = Integer.valueOf(warehouse.Length__c);
        this.maxCellLevel = Integer.valueOf(warehouse.Max_Cell_Level__c);
        this.cellList = obtainCellList(warehouse.Id);
        this.cellIdToContainerMap = createCellIdToContainerMap();
        this.warehouseMatrix = createWarehouseMatrix();
    }

    /**
     * @description  Getter for warehouse width.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public Integer getWidth() {
        return this.width;
    }

    /**
     * @description  Getter for warehouse length.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public Integer getLength() {
        return this.length;
    }

    /**
     * @description  Getter for warehouse max cell level.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public Integer getMaxCellLevel() {
        return this.maxCellLevel;
    }

    /**
     * @description  Getter for warehouse matrixs structure.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public List<List<List<Warehouse_Cell__c>>> getWarehouseMatrix() {
        return this.warehouseMatrix;
    }

    /**
     * @description  Getter for warehouse cell list.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public List<Warehouse_Cell__c> getCellList() {
        return this.cellList;
    }

    /**
     * @description  Getter for cellIdToContainerMap.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public Map<Id, Container__c> getCellIdToContainerMap() {
        return this.cellIdToContainerMap;
    }

    private List<Warehouse_Cell__c> obtainCellList(Id warehouseId) {
        return [SELECT Address__c,
                       Level__c,
                       Is_Empty__c,
                       (SELECT Id, Issuance_Date__c, Status__c FROM Containers__r)
                FROM Warehouse_Cell__c
                WHERE Container_Warehouse__c = :warehouseId];
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