public inherited sharing class TB_vu_MultipartFormBuilder
{
    private static final String BOUNDARY = '1ff13444ed8140c7a32fc4e6451aa76d';
    
    public static final String CONTENT_TYPE = 'multipart/form-data; charset="UTF-8"; boundary="' + BOUNDARY + '"';
    
    private static String safelyPad(String value, String valueCrLf64, String lineBreaks)
    {
        String valueCrLf = '';
        Blob valueCrLfBlob = null;
        
        while(valueCrLf64.endsWith('='))
        {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = Blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }
        
        return valueCrLf64;
    }
    
    public static String writeBoundary()
    {
        String value = '--' + BOUNDARY + '\r\n';
        Blob valueBlob = Blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }
    
    public static String writeBoundary(EndingType ending)
    {
        String value = '';
        
        if(ending == EndingType.Cr)
        {
            value += '\n';
        }
        else if(ending == EndingType.None)
        {
            value += '\r\n';
        }
        value += '--' + BOUNDARY + '--';
        
        return EncodingUtil.base64Encode(Blob.valueOf(value));
    }
    
    public static WriteFileResult writeFile(String key, String value, String mimeType, Blob fileBlob)
    {
        EndingType ending = EndingType.None;
        String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"; filename="' + value + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n';
        Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String content = safelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');
        String contentType = 'Content-Type: ' + mimeType;
        String contentTypeCrLf = contentType + '\r\n\r\n';
        Blob contentTypeCrLfBlob = Blob.valueOf(contentTypeCrLf);
        String contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);
        
        content += safelyPad(contentType, contentTypeCrLf64, '\r\n\r\n');
        
        String file64 = EncodingUtil.base64Encode(fileBlob);
        Integer file64Length = file64.length();
        String file64Ending = file64.substring(file64Length - 3, file64Length);
        
        if(file64Ending.endsWith('=='))
        {
            file64Ending = file64Ending.substring(0, 1) + '0K';//   0K = \r\n
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.CrLf;
        }
        else if(file64Ending.endsWith('='))
        {
            file64Ending = file64Ending.substring(0, 2) + 'N';//    N = \r
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.Cr;
        }
        
        content += file64;
        
        return new WriteFileResult(content, ending);
    }
    
    public static String writeBodyParameter(String key, String value)
    {
        String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String content = safelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        String valueCrLf = value + '\r\n';
        Blob valueCrLfBlob = Blob.valueOf(valueCrLf);
        String valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        
        content += safelyPad(value, valueCrLf64, '\r\n');
        
        return content;
    }
    
    public class WriteFileResult
    {
        public final String content { get; private set; }
        public final EndingType endingType { get; private set; }
        
        public WriteFileResult(String content, EndingType ending)
        {
            this.content = content;
            this.endingType = ending;
        }
    }
    
    public enum EndingType
    {
        Cr,
        CrLf,
        None
    }
}