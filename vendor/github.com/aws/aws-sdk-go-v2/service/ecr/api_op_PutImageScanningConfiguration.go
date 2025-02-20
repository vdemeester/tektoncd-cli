// Code generated by smithy-go-codegen DO NOT EDIT.

package ecr

import (
	"context"
	"fmt"
	awsmiddleware "github.com/aws/aws-sdk-go-v2/aws/middleware"
	"github.com/aws/aws-sdk-go-v2/service/ecr/types"
	"github.com/aws/smithy-go/middleware"
	smithyhttp "github.com/aws/smithy-go/transport/http"
)

// The PutImageScanningConfiguration API is being deprecated, in favor of
// specifying the image scanning configuration at the registry level. For more
// information, see PutRegistryScanningConfiguration.
//
// Updates the image scanning configuration for the specified repository.
func (c *Client) PutImageScanningConfiguration(ctx context.Context, params *PutImageScanningConfigurationInput, optFns ...func(*Options)) (*PutImageScanningConfigurationOutput, error) {
	if params == nil {
		params = &PutImageScanningConfigurationInput{}
	}

	result, metadata, err := c.invokeOperation(ctx, "PutImageScanningConfiguration", params, optFns, c.addOperationPutImageScanningConfigurationMiddlewares)
	if err != nil {
		return nil, err
	}

	out := result.(*PutImageScanningConfigurationOutput)
	out.ResultMetadata = metadata
	return out, nil
}

type PutImageScanningConfigurationInput struct {

	// The image scanning configuration for the repository. This setting determines
	// whether images are scanned for known vulnerabilities after being pushed to the
	// repository.
	//
	// This member is required.
	ImageScanningConfiguration *types.ImageScanningConfiguration

	// The name of the repository in which to update the image scanning configuration
	// setting.
	//
	// This member is required.
	RepositoryName *string

	// The Amazon Web Services account ID associated with the registry that contains
	// the repository in which to update the image scanning configuration setting. If
	// you do not specify a registry, the default registry is assumed.
	RegistryId *string

	noSmithyDocumentSerde
}

type PutImageScanningConfigurationOutput struct {

	// The image scanning configuration setting for the repository.
	ImageScanningConfiguration *types.ImageScanningConfiguration

	// The registry ID associated with the request.
	RegistryId *string

	// The repository name associated with the request.
	RepositoryName *string

	// Metadata pertaining to the operation's result.
	ResultMetadata middleware.Metadata

	noSmithyDocumentSerde
}

func (c *Client) addOperationPutImageScanningConfigurationMiddlewares(stack *middleware.Stack, options Options) (err error) {
	if err := stack.Serialize.Add(&setOperationInputMiddleware{}, middleware.After); err != nil {
		return err
	}
	err = stack.Serialize.Add(&awsAwsjson11_serializeOpPutImageScanningConfiguration{}, middleware.After)
	if err != nil {
		return err
	}
	err = stack.Deserialize.Add(&awsAwsjson11_deserializeOpPutImageScanningConfiguration{}, middleware.After)
	if err != nil {
		return err
	}
	if err := addProtocolFinalizerMiddlewares(stack, options, "PutImageScanningConfiguration"); err != nil {
		return fmt.Errorf("add protocol finalizers: %v", err)
	}

	if err = addlegacyEndpointContextSetter(stack, options); err != nil {
		return err
	}
	if err = addSetLoggerMiddleware(stack, options); err != nil {
		return err
	}
	if err = addClientRequestID(stack); err != nil {
		return err
	}
	if err = addComputeContentLength(stack); err != nil {
		return err
	}
	if err = addResolveEndpointMiddleware(stack, options); err != nil {
		return err
	}
	if err = addComputePayloadSHA256(stack); err != nil {
		return err
	}
	if err = addRetry(stack, options); err != nil {
		return err
	}
	if err = addRawResponseToMetadata(stack); err != nil {
		return err
	}
	if err = addRecordResponseTiming(stack); err != nil {
		return err
	}
	if err = addSpanRetryLoop(stack, options); err != nil {
		return err
	}
	if err = addClientUserAgent(stack, options); err != nil {
		return err
	}
	if err = smithyhttp.AddErrorCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = smithyhttp.AddCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = addSetLegacyContextSigningOptionsMiddleware(stack); err != nil {
		return err
	}
	if err = addTimeOffsetBuild(stack, c); err != nil {
		return err
	}
	if err = addUserAgentRetryMode(stack, options); err != nil {
		return err
	}
	if err = addOpPutImageScanningConfigurationValidationMiddleware(stack); err != nil {
		return err
	}
	if err = stack.Initialize.Add(newServiceMetadataMiddleware_opPutImageScanningConfiguration(options.Region), middleware.Before); err != nil {
		return err
	}
	if err = addRecursionDetection(stack); err != nil {
		return err
	}
	if err = addRequestIDRetrieverMiddleware(stack); err != nil {
		return err
	}
	if err = addResponseErrorMiddleware(stack); err != nil {
		return err
	}
	if err = addRequestResponseLogging(stack, options); err != nil {
		return err
	}
	if err = addDisableHTTPSMiddleware(stack, options); err != nil {
		return err
	}
	if err = addSpanInitializeStart(stack); err != nil {
		return err
	}
	if err = addSpanInitializeEnd(stack); err != nil {
		return err
	}
	if err = addSpanBuildRequestStart(stack); err != nil {
		return err
	}
	if err = addSpanBuildRequestEnd(stack); err != nil {
		return err
	}
	return nil
}

func newServiceMetadataMiddleware_opPutImageScanningConfiguration(region string) *awsmiddleware.RegisterServiceMetadata {
	return &awsmiddleware.RegisterServiceMetadata{
		Region:        region,
		ServiceID:     ServiceID,
		OperationName: "PutImageScanningConfiguration",
	}
}
