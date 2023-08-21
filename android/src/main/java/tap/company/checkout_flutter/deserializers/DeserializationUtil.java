package tap.company.checkout_flutter.deserializers;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import company.tap.checkout.internal.api.enums.AddressType;
import company.tap.checkout.internal.api.enums.AmountModificatorType;
import company.tap.checkout.internal.api.enums.PaymentType;
import company.tap.checkout.open.enums.TransactionMode;
import company.tap.checkout.open.models.AddressModel;
import company.tap.checkout.open.models.AuthorizeAction;
import company.tap.checkout.internal.api.models.PhoneNumber;
import company.tap.checkout.open.models.Destination;
import company.tap.checkout.open.models.ItemsModel;
import company.tap.checkout.open.models.Receipt;
import company.tap.checkout.open.models.Reference;
import company.tap.checkout.open.enums.CardType;
import company.tap.checkout.open.enums.SdkMode;
import company.tap.checkout.open.models.PaymentItem;
import company.tap.checkout.open.models.Shipping;
import company.tap.checkout.open.models.TapCustomer;
import company.tap.checkout.open.models.Tax;

public class DeserializationUtil {
    static private boolean isValidJson(String jsonString) {
        System.out.println("json string:::: " + jsonString);
        try {
            new JSONObject(jsonString);
            return true;
        } catch (JSONException e) {
            return false;
        }
    }

    static private JsonElement getJsonElement(String jsonString, String type) {
        JsonElement jsonElement;
        if ("array".equalsIgnoreCase(type)) {
            JsonArray jsonArray = (JsonArray) JsonParser.parseString(jsonString);
            jsonElement = jsonArray;
        } else {
            JsonObject jsonObject = (JsonObject) JsonParser.parseString(jsonString);
            jsonElement = jsonObject;
        }
        return jsonElement;
    }


    // taxes
    static public ArrayList<Tax> getTaxes(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<Tax>>() {
        }.getType();
        List<Tax> taxesList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<Tax>) taxesList;
    }


    // items
    static public ArrayList<ItemsModel> getPaymentItems(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<ItemsModel>>() {
        }.getType();
        List<ItemsModel> taxesList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<ItemsModel>) taxesList;
    }


    // metadata
    static public HashMap<String, String> getMetaData(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<HashMap<String, String>>() {
        }.getType();
        HashMap<String, String> metaMap = new Gson().fromJson(jsonElement, listType);
        System.out.println(metaMap.size());
        return metaMap;
    }


    public static Reference getReference(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Reference>() {
        }.getType();
        Reference reference = new Gson().fromJson(jsonElement, listType);
        System.out.println(reference.getClass());
        return reference;
    }

    public static Receipt getReceipt(Object jsonString) {
        System.out.println("Inside get recipet");
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Receipt>() {
        }.getType();
        Receipt receipt = new Gson().fromJson(jsonElement, listType);
        System.out.println(receipt.getClass());
        return receipt;
    }

    public static Shipping getShipping(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Shipping>() {
        }.getType();
        Shipping shipping = new Gson().fromJson(jsonElement, listType);
        System.out.println(shipping.getDescription());
        return shipping;
    }


    public static AuthorizeAction getAuthorizeAction(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<AuthorizeAction>() {
        }.getType();
        AuthorizeAction authorizeAction = new Gson().fromJson(jsonElement, listType);
        System.out.println("authorizeAction : " + authorizeAction.getClass());
        return authorizeAction;
    }

    // items
    static public ArrayList<Destination> getDestinations(Object jsonString) {
        if (jsonString == null)
            return null;
        if (!isValidJson(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<Destination>>() {
        }.getType();
        List<Destination> destinationsList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<Destination>) destinationsList;
    }


    public static TapCustomer getCustomer(HashMap<String, Object> sessionParameters) {
        System.out.println("customer object >>>>> " + sessionParameters.get("customer"));
        if (sessionParameters.get("customer") == null || "null".equalsIgnoreCase(sessionParameters.get("customer").toString()))
            return null;
        String customerString = (String) sessionParameters.get("customer");

        JSONObject jsonObject;
        try {
            assert customerString != null;
            jsonObject = new JSONObject(customerString);
            String phone = jsonObject.get("phone").toString();
            JSONObject phoneJsonObject;
            phoneJsonObject = new JSONObject(phone);
            System.out.println("phone object >>>>> " + phone);
            PhoneNumber phoneNumber = new PhoneNumber(phoneJsonObject.get("country_code").toString(), phoneJsonObject.get("number").toString());

            String address = jsonObject.get("phone").toString();
            JSONObject addressJsonObject;
            addressJsonObject = new JSONObject(phone);
            System.out.println("phone object >>>>> " + phone);
            // Need to set data for address model
            AddressModel addressModel = new AddressModel();


            System.out.println("Phone Number >>>> " + phoneNumber);
            return new TapCustomer.CustomerBuilder(jsonObject.get("id").toString()).firstName(jsonObject.get("first_name").toString())
                    .lastName(jsonObject.get("last_name").toString()).phone(phoneNumber)
                    .middleName(jsonObject.get("middle_name").toString()).build();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static TransactionMode getTransactionMode(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return TransactionMode.PURCHASE;
        System.out.println("trxMode >>>> " + jsonString);
        switch (jsonString) {
            case "PURCHASE":
                return TransactionMode.PURCHASE;
            case "AUTHORIZE_CAPTURE":
                return TransactionMode.AUTHORIZE_CAPTURE;
            case "SAVE_CARD":
                return TransactionMode.SAVE_CARD;
            case "TOKENIZE_CARD":
                return TransactionMode.TOKENIZE_CARD;
        }
        return TransactionMode.PURCHASE;
    }

    public static CardType getCardType(String jsonString) {
        System.out.println("CARD TYPE " + jsonString);
        if (jsonString == null || jsonString == CardType.ALL.toString() ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return CardType.ALL;
        System.out.println("card type >>>> " + jsonString);
        if ("CREDIT".equalsIgnoreCase(jsonString)) {
            return CardType.CREDIT;
        } else if ("DEBIT".equalsIgnoreCase(jsonString)) return CardType.DEBIT;
        return CardType.ALL;
    }

    public static String getPaymentType(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return PaymentType.CARD.getPaymentType();

        System.out.println("payment type >>>> " + jsonString);
        switch (jsonString) {
            case "Card":
                return PaymentType.CARD.getPaymentType();
            case "Web":
                return PaymentType.WEB.getPaymentType();
            case "SavedCard":
                return PaymentType.SavedCard.getPaymentType();
            case "Telecom":
                return PaymentType.telecom.getPaymentType();
        }
        return PaymentType.CARD.getPaymentType();

    }

    public static SdkMode getSDKMode(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return SdkMode.SAND_BOX;
        System.out.println("SDK Mode >>>> " + jsonString);
        switch (jsonString) {
            case "Sandbox":
                return SdkMode.SAND_BOX;
            case "Production":
                return SdkMode.PRODUCTION;
        }
        return SdkMode.SAND_BOX;
    }

    public static AddressType getAddressType(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return AddressType.RESIDENTIAL;
        System.out.println("Address type >>>> " + jsonString);
        switch (jsonString) {
            case "Residential":
                return AddressType.RESIDENTIAL;
            case "Commercial":
                return AddressType.COMMERCIAL;
        }
        return AddressType.RESIDENTIAL;
    }

    public static AmountModificatorType getAmountModificationType(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return AmountModificatorType.FIXED;
        System.out.println("Amount modification type >>>> " + jsonString);
        switch (jsonString) {
            case "Fixed":
                return AmountModificatorType.FIXED;
            case "Percentage":
                return AmountModificatorType.PERCENTAGE;
        }
        return AmountModificatorType.FIXED;
    }


}
