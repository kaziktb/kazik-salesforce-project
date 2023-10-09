public with sharing class TB_QueryBuilder {
    private final static String ID_FIELD = 'Id';
    private final static String QUOTE = '\'';
    private final static String SELECT_CLAUSE = ' SELECT ';
    private final static String FROM_CLAUSE = ' FROM ';
    private final static String WHERE_CLAUSE = ' WHERE ';
    private final static String ORDER_CLAUSE = ' ORDER BY ';
    private final static String DESC_CLAUSE = ' DESC ';
    private final static String LIMIT_CLAUSE = ' LIMIT ';
    private final static String OPEN_BRACKET = ' ( ';
    private final static String CLOSED_BRACKET = ' ) ';
    private final static String EQUAL_CON = ' = ';
    private final static String NOT_EQUAL_CON = ' != ';
    private final static String MORE_CON = ' > ';
    private final static String LESS_CON = ' < ';
    private final static String IN_CON = ' IN ';
    private final static String LIKE_CON = ' LIKE ';
    private final static String AND_CON = ' AND ';
    private final static String OR_CON = ' OR ';
    private final static String OPEN_SET = ' ( ';
    private final static String CLOSED_SET = ' ) ';
    private final static String OPEN_TO_LABEL = ' toLabel(';
    private final static String CLOSE_TO_LABEL = ') ';

    public static MainQuery create() {
        return new MainQuery();
    }

    public class IncompleteQueryException extends Exception {}

    public with sharing abstract class Query {
        private Set<String> fieldsToSelect = new Set<String>();
        private List<Condition> conditions = new List<Condition>();
        private MainQuery parent;
        private String selectPart {
            get { return getSelector(); }
        }
        private String fromPart;
        private String wherePart{
            get { return getConditions(); }
        }
        private String orderPart;
        private String limitPart;
        public Boolean hasConditions {
            get { return !conditions.isEmpty(); }
        }
        public Boolean hasLimit {
            get { return limitPart != null; }
        }
        public Boolean hasOrder {
            get { return orderPart != null; }
        }
        public Boolean isValid = true;
        private Set<InnerQuery> innerQueries = new Set<InnerQuery>();
        private Boolean openingBracketFlag = false;

        public abstract String getSelector();

        public String getQuery() {
            String result = SELECT_CLAUSE + selectPart + FROM_CLAUSE + fromPart;
            result = hasConditions ? result + WHERE_CLAUSE + wherePart : result;
            result = hasOrder ? result + ORDER_CLAUSE + orderPart : result;
            result = hasLimit ? result + LIMIT_CLAUSE + limitPart : result;
            return result;
        }

        public String getConditions() {
            String result = '';
            Integer numberOfConditions = conditions.size();
            for (Integer i = 0; i < numberOfConditions; i++) {
                result = result + conditions.get(i).getAsString(i != 0);
            }
            return result;
        }

        public Query openConditionBracket() {
            openingBracketFlag = true;
            return this;
        }

        public Query closeConditionBracket() {
            if (!conditions.isEmpty()) {
                conditions[conditions.size() - 1].closeBracket();
            }
            return this;
        }

        private Query addCondition(Condition condition) {
            if (openingBracketFlag) {
                condition.openBracket();
                openingBracketFlag = false;
            }
            conditions.add(condition);
            return this;
        }

        public Query selectField(String fieldApiName) {
            fieldsToSelect.add(fieldApiName);
            return this;
        }

        public Query selectFields(List<String> fieldApiNames) {
            fieldsToSelect.addAll(fieldApiNames);
            return this;
        }

        public Query selectFields(Set<String> fieldApiNames) {
            fieldsToSelect.addAll(fieldApiNames);
            return this;
        }

        public Query addFieldLabelTo(String fieldApiName) {
            if (fieldsToSelect.contains(fieldApiName)) {
                fieldsToSelect.remove(fieldApiName);
                selectFieldLabel(fieldApiName);
            }
            return this;
        }

        public Query selectFieldLabel(String fieldApiName) {
            fieldsToSelect.add(OPEN_TO_LABEL + fieldApiName + CLOSE_TO_LABEL);
            return this;
        }

        public Query selectFieldsLabels(List<String> fieldApiNames) {
            for (String fieldApiName : fieldApiNames) {
                selectFieldLabel(fieldApiName);
            }
            return this;
        }

        public Query selectId() {
            return selectField(ID_FIELD);
        }

        public Query fromSObject(String objectApiName) {
            fromPart = objectApiName;
            return this;
        }

        public Query limitResult(Integer maxNumberOfResult) {
            limitPart = String.valueOf(maxNumberOfResult);
            return this;
        }

        public Query orderResult(String fieldToOrder) {
            orderPart = fieldToOrder;
            return this;
        }

        public Query orderResult(Set<String> fieldsToOrder) {
            orderPart = TB_SObjectUtils.getFieldsToSelectAsString(fieldsToOrder);
            return this;
        }

        public Query orderResultDesc(String fieldToOrder) {
            orderResult(fieldToOrder);
            orderPart = orderPart + DESC_CLAUSE;
            return this;
        }

        public Query orderResultDesc(Set<String> fieldsToOrder) {
            orderResult(fieldsToOrder);
            orderPart = orderPart + DESC_CLAUSE;
            return this;
        }

        public Query andWhereIdIsEqual(String value) {
            andWhereFieldIsEqual('Id', value);
            return this;
        }

        public Query andWhereFieldIsNull(String field) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.EQUAL_CON, field));
            return this;
        }

        public Query andWhereFieldIsEqual(String field, Object value) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.EQUAL_CON, field, value));
            return this;
        }

        public Query andWhereFieldsAreNotEqual(List<String> fields, Object value) {
            for (String field : fields) {
                addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.NOT_EQUAL_CON, field, value));
            }
            return this;
        }

        public Query andWhereFieldIsNotEqual(String field, Object value) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.NOT_EQUAL_CON, field, value));
            return this;
        }

        public Query andWhereFieldIsNotNull(String field) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.NOT_EQUAL_CON, field));
            return this;
        }

        public Query andWhereFieldIsMore(String field, Object value) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.MORE_CON, field, value));
            return this;
        }

        public Query andWhereFieldIsLess(String field, Object value) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.LESS_CON, field, value));
            return this;
        }

        public Query andWhereFieldIsLike(String field, Object value) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.LIKE_CON, field, value));
            return this;
        }

        public Query andWhereFieldIsInSet(String field, Set<String> values) {
            addCondition(new Condition(ConditionType.AND_CON, ConditionComparison.IN_CON, field, values));
            return this;
        }

        public Query orWhereFieldIsNull(String field) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.EQUAL_CON, field));
            return this;
        }

        public Query orWhereFieldIsEqual(String field, Object value) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.EQUAL_CON, field, value));
            return this;
        }

        public Query orWhereFieldsAreEqual(List<String> fields, Object value) {
            for (String field : fields) {
                addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.EQUAL_CON, field, value));
            }
            return this;
        }

        public Query orWhereFieldIsNotNull(String field) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.NOT_EQUAL_CON, field));
            return this;
        }

        public Query orWhereFieldIsNotEqual(String field, Object value) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.NOT_EQUAL_CON, field, value));
            return this;
        }

        public Query orWhereFieldIsMore(String field, Object value) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.MORE_CON, field, value));
            return this;
        }

        public Query orWhereFieldIsLike(String field, Object value) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.LIKE_CON, field, value));
            return this;
        }

        public Query orWhereFieldIsInSet(String field, Set<Object> values) {
            addCondition(new Condition(ConditionType.OR_CON, ConditionComparison.IN_CON, field, values));
            return this;
        }

        public Query isOpeningBracketCondition() {
            if (!conditions.isEmpty()) {
                conditions.get(conditions.size() - 1).openBracket();
            }
            return this;
        }

        public Query isClosingBracketCondition() {
            if (!conditions.isEmpty()) {
                conditions.get(conditions.size() - 1).closeBracket();
            }
            return this;
        }

        public InnerQuery openInnerQuery() {
            InnerQuery innerQuery = new InnerQuery((MainQuery) this);
            innerQueries.add(innerQuery);
            return innerQuery;
        }

        public InnerQuery openInnerQuery(String objectApiName, String relationFieldApiName) {
            InnerQuery innerQuery = openInnerQuery();
            innerQuery.fromSObject(objectApiName, relationFieldApiName);
            return innerQuery;
        }

        public InnerQuery openInnerQuery(String parentApiName, String objectApiName, String relationFieldApiName) {
            InnerQuery innerQuery = openInnerQuery();
            innerQuery.fromSObject(parentApiName, objectApiName, relationFieldApiName);
            return innerQuery;
        }

        public Query closeInnerQuery() {
            return parent;
        }

        public List<SObject> perform() {
            List<SObject> result;
            if (fromPart == null || selectPart == null) {
                throw new IncompleteQueryException();
            }
            try {
                result = Database.query(getQuery());
            } catch (Exception ex) {
                isValid = false;
                insert TB_LogUtils.registerLog(ex);
            }
            return result;
        }

        public Map<Id, SObject> performMap() {
            Map<Id, SObject> result;
            if (fromPart == null || selectPart == null) {
                throw new IncompleteQueryException();
            }
            try {
                result = new Map<Id, SObject>(Database.query(getQuery()));
            } catch (Exception ex) {
                isValid = false;
                insert TB_LogUtils.registerLog(ex);
            }
            return result;
        }

        public SObject performSingle() {
            SObject result;
            if (fromPart == null || selectPart == null) {
                throw new IncompleteQueryException();
            }
            try {
                result = Database.query(getQuery());
            } catch (Exception ex) {
                isValid = false;
                insert TB_LogUtils.registerLog(ex);
            }
            return result;
        }

        public SObject performSingleWithNull() {
            SObject result;
            if (fromPart == null || selectPart == null) {
                throw new IncompleteQueryException();
            }
            try {
                result = Database.query(getQuery());
            } catch (Exception ex) {
                isValid = false;
            }
            return result;
        }
    }

    public with sharing class MainQuery extends Query {
        public override String getSelector() {
            Set<String> selectParts = new Set<String>();
            selectParts.addAll(fieldsToSelect);
            if (!innerQueries.isEmpty()) {
                List<String> innerQueriesAsStrings = new List<String>();
                for (InnerQuery innerQuery : innerQueries) {
                    innerQueriesAsStrings.add(OPEN_BRACKET + innerQuery.getQuery() + CLOSED_BRACKET);
                }
                selectParts.addAll(innerQueriesAsStrings);
            }
            if (selectParts.isEmpty()) {
                throw new IncompleteQueryException();
            }
            return TB_SObjectUtils.getFieldsToSelectAsString(selectParts);
        }
    }

    public class InnerQuery extends Query {
        private InnerQuery(MainQuery parent) {
            this.parent = parent;
        }

        public override String getSelector() {
            if (fieldsToSelect.isEmpty()) {
                throw new IncompleteQueryException();
            }
            return TB_SObjectUtils.getFieldsToSelectAsString(fieldsToSelect);
        }

        public InnerQuery fromSObject(String childApiName, String relationFieldApiName) {
            if (parent.fromPart == null) {
                throw new IncompleteQueryException();
            }
            fromPart = TB_SObjectUtils.getParentRelationNameFrom(parent.fromPart, childApiName, relationFieldApiName);
            return this;
        }

        public InnerQuery fromSObject(String parentApiName, String childApiName, String relationFieldApiName) {
            fromPart = TB_SObjectUtils.getParentRelationNameFrom(parentApiName, childApiName, relationFieldApiName);
            return this;
        }
    }

    public enum ConditionType {OR_CON, AND_CON}
    public enum ConditionOrder {WITHOUT, OPEN, CLOSED}
    public enum ConditionComparison {EQUAL_CON, NOT_EQUAL_CON, MORE_CON, LESS_CON, IN_CON, LIKE_CON}

    public class Condition {
        private ConditionType type;
        private ConditionOrder order;
        private ConditionComparison comparison;
        private String firstPart;
        private Object lastPart;
        private Set<String> lastParts;
        public Boolean isIntegerValue = false;
        public Boolean isBooleanValue = false;
        public Boolean isStringValue = false;

        public Condition(
                ConditionType type,
                ConditionComparison comparison,
                String firstPart
        ) {
            this.type = type;
            this.order = ConditionOrder.WITHOUT;
            this.comparison = comparison;
            this.firstPart = firstPart;
            this.lastPart = 'null';
        }

        public Condition(
                ConditionType type,
                ConditionComparison comparison,
                String firstPart,
                Object lastPart
        ) {
            this(type, comparison, firstPart);
            this.lastPart = lastPart;
            if (lastPart != null && lastPart instanceof Boolean) {
                this.isBooleanValue = true;
            } else if(lastPart != null && lastPart instanceof Integer) {
                this.isIntegerValue = true;
            } else if(lastPart != null && lastPart instanceof String) {
                this.isStringValue = true;
            } else {
                this.lastPart = 'null';
            }
        }

        public Condition(
                ConditionType type,
                ConditionComparison comparison,
                String firstPart,
                Set<String> lastParts
        ) {
            this(type, comparison, firstPart);
            this.lastParts = lastParts;
            this.isIntegerValue = false;
        }

        private String withQuotes(String value) {
            return QUOTE + value + QUOTE;
        }

        private String asStringSet(Set<String> values) {
            List<String> valuesWithQuotes = new List<String>();
            for (String value : values) {
                valuesWithQuotes.add(withQuotes(value));
            }
            return OPEN_SET + TB_SObjectUtils.getFieldsToSelectAsString(valuesWithQuotes) + CLOSED_SET;
        }

        public String getAsString() {
            return getAsString(true);
        }

        public Condition openBracket() {
            order = ConditionOrder.OPEN;
            return this;
        }

        public Condition closeBracket() {
            order = ConditionOrder.CLOSED;
            return this;
        }

        public String getAsString(Boolean withType) {
            String result = order == ConditionOrder.OPEN ? OPEN_BRACKET + firstPart : firstPart;
            switch on comparison {
                when EQUAL_CON {
                    result = result + EQUAL_CON;
                }
                when NOT_EQUAL_CON {
                    result = result + NOT_EQUAL_CON;
                }
                when MORE_CON {
                    result = result + MORE_CON;
                }
                when LESS_CON {
                    result = result + LESS_CON;
                }
                when IN_CON {
                    result = result + IN_CON;
                }
                when LIKE_CON {
                    result = result + LIKE_CON;
                }
            }
            if (comparison == ConditionComparison.IN_CON) {
                result = result + asStringSet(lastParts);
            } else {
                result = result + (isStringValue ? withQuotes(String.valueOf(lastPart)) : String.valueOf(lastPart));
            }
            result = order == ConditionOrder.CLOSED ? result + CLOSED_BRACKET : result;
            if (withType) {
                switch on type {
                    when OR_CON {
                        result = OR_CON + result;
                    }
                    when AND_CON {
                        result = AND_CON + result;
                    }
                }
            }
            return result;
        }
    }
}