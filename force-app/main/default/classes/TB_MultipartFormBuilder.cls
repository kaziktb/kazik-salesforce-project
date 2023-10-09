/**
 * Created by pilar on 01.12.2021.
 */

public inherited sharing class TB_MultipartFormBuilder {
    private final static String BOUNDARY = '4ae13123ac9123c7a32fd5e6451bb87e';
    public static final String CONTENT_TYPE = 'multipart/form-data; charset="UTF-8"; boundary="' + BOUNDARY + '"';

    private String currentBase64Body = '';


    public Blob getResultAsBlob() {
        return EncodingUtil.base64Decode(currentBase64Body);
    }

    public TB_MultipartFormBuilder writeBoundary() {
        String value = '--' + BOUNDARY + '\r\n';
        Blob valueBlob = Blob.valueOf(value);

        this.currentBase64Body += EncodingUtil.base64Encode(valueBlob);
        return this;
    }

    public TB_MultipartFormBuilder writeFileEndingBoundary(EndingType ending) {
        String value = '';

        if (ending == EndingType.Cr) {
            value += '\n';
        } else if (ending == EndingType.None) {
            value += '\r\n';
        }
        value += '--' + BOUNDARY + '--';


        Blob valueBlob = Blob.valueOf(value);

        this.currentBase64Body += EncodingUtil.base64Encode(valueBlob);
        return this;
    }

    public TB_MultipartFormBuilder writeBodyJSON(String value) {
        String header = 'Content-Disposition: form-data;name="entity_document";\r\nContent-Type: application/json';
        String headerCrLf = header + '\r\n\r\n';
        Blob contentDispositionCrLfBlob = Blob.valueOf(headerCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String content = safelyPad(header, contentDispositionCrLf64, '\r\n\r\n');
        String valueCrLf = value + '\r\n\r\n';
        Blob valueCrLfBlob = Blob.valueOf(valueCrLf);
        String valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        currentBase64Body += content + safelyPad(value, valueCrLf64, '\r\n');

        return this;
    }

    public TB_MultipartFormBuilder writeFile(String filename, String mimeType, Blob fileBlob) {
        String contentDisposition = 'Content-Disposition: form-data; name="Body"; filename="' + filename + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n';
        Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String content = safelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');
        String contentType = 'Content-Type: ' + mimeType;
        String contentTypeCrLf = contentType + '\r\n\r\n';
        Blob contentTypeCrLfBlob = Blob.valueOf(contentTypeCrLf);
        String contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);

        content += safelyPad(contentType, contentTypeCrLf64, '\r\n\r\n');

        String file64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==';
        Integer file64Length = file64.length();
        String file64Ending = file64.substring(file64Length - 3, file64Length);

        EndingType ending = EndingType.None;
        if (file64Ending.endsWith('==')) {
            file64Ending = file64Ending.substring(0, 1) + '0K';//   0K = \r\n
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.CrLf;
        } else if (file64Ending.endsWith('=')) {
            file64Ending = file64Ending.substring(0, 2) + 'N';//    N = \r
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.Cr;
        }

//        content += file64;

        this.currentBase64Body += content;
        this.writeFileEndingBoundary(ending);
        return this;
    }

    private static String safelyPad(String value, String valueCrLf64, String lineBreaks) {
        Blob valueCrLfBlob = null;

        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            String valueCrLf = value + lineBreaks;
            valueCrLfBlob = Blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }

        return valueCrLf64;
    }

    public enum EndingType {
        Cr,
        CrLf,
        None
    }
}