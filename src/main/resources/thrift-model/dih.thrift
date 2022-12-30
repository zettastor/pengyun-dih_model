 include "shared.thrift"
// include "icshared.thrift"

/**
 * This thrift defines interfaces and data structs to gossip instances. 
 * Gossip protocol uses modified gossiping protocol.
 *
 */

namespace java py.thrift.distributedinstancehub.service
namespace perl dih

enum InstanceStatusThrift{
    HEALTHY = 1,
    SUSPEND = 2,
    SICK = 3,
    FAILED = 4,
    DISUSED = 5
}

struct EndPointThrift{
    1: string host,
    2: i32 port
}

enum DcTypeThrift {
    NORMALSUPPORT = 0,
    SCSISUPPORT = 1,
    ALLSUPPORT = 2
}

struct InstanceThrift{
    1: i64 instanceId,
    2: shared.GroupThrift group,
    3: map<i32, EndPointThrift> endPoints,
    4: InstanceStatusThrift status, 
    5: string name,
    6: i32 heartBeatCounter,
    7: i64 checksum,
    9: optional string location,
    10: optional bool netSubHealth,
    11: optional DcTypeThrift dcType;
}

struct SessionIdThrift {
    1: i64 initiatorId,
    2: i64 fellowId
}

struct HeartBeatInfoThrift {
    1: i64 instanceId,
    2: i32 heartBeat
}

struct BootstrapRequest {
    1: i64 requestId,
    2: InstanceThrift instance
}

struct BootstrapResponse {
    1: i64 requestId,
    2: i32 heartbeatCounter
}

struct BootstrapToRequest {
    1: i64 requestId,

    // endpoint of DIH to which the processing DIH should bootstrap
    2: EndPointThrift endpoint,
}

struct BootstrapToResponse {
    1: i64 requestId,
    2: i32 heartBeat
}

struct HeartBeatRequest {
    1: i64 requestId,
    2: InstanceThrift instance
}

struct HeartBeatResponse{
    1: i64 requestId
}

struct GetInstanceRequest{
    1: i64 requestId,
    2: optional i64 instanceId,
    3: optional string name,
    4: optional string location 
}

struct GetInstanceResponse{
    1: i64 requestId,
    2: list<InstanceThrift> instanceList

}

struct TurnInstanceToFailedRequest{
    1: i64 requestId,
    2: i64 instanceId
}

struct TurnInstanceToFailedResponse{
    1: i64 requestId
}

struct CheckTotalFingerprintRequest {
    1: i64 requestId,
    2: SessionIdThrift sessionId,
    3: byte maskLen,
    4: i64 totalFingerprint,
}

struct CheckTotalFingerprintResponse {
    1: i64 requestId,
    2: byte maskLen,
    3: optional map<i32, i64> fingerprintTable,
}

struct CheckInstanceChecksumRequest {
    1: i64 requestId,
    2: SessionIdThrift sessionId,
    3: map<i64, i64> checksumTable,
    4: optional list<i32> mismatchedPartitions
}

struct CheckInstanceChecksumResponse {
    1: i64 requestId,
    2: list<InstanceThrift> instances,
    3: list<i64> missingInstances
}

struct UpdateInstanceRequest {
    1: i64 requestId,
    2: SessionIdThrift sessionId,
    3: list<InstanceThrift> instances
}

struct UpdateInstanceResponse {
    1: i64 requestId,
}

struct UpdateHeartbeatRequest {
    1: i64 requestId,
    2: SessionIdThrift sessionId,
    3: list<HeartBeatInfoThrift> heartBeatInfo
}

struct UpdateHeartbeatResponse {
    1: i64 responseId,
    2: list<HeartBeatInfoThrift> heartBeatInfo
}

struct Syslog {
    1: string sourceObject,
    2: string timeStamp,
    3: string description,
    4: string level,
    5: string type,
    6: bool alarmAppear
}

struct GetSyslogRequest {
    1: i64 requestId,
    2: i64 lastReportTime,
}

struct GetSyslogResponse {
    1: i64 responseId,
    2: list<Syslog> syslogs,
}

exception SessionDeniedExceptionThrift {
    1: optional string detail
}

exception BootstrapDeniedExceptionThrift {
    1: optional string detail
}

exception NotDihExceptionThrift {
    1: optional string detail
}

//
service DistributedInstanceHub extends shared.DebugConfigurator {
    void ping(),

    void shutdown(),

    CheckTotalFingerprintResponse checkTotalFingerprint(1: CheckTotalFingerprintRequest request) throws (1:SessionDeniedExceptionThrift sde,
                                                                                                         2:shared.ServiceHavingBeenShutdownThrift shbsd),

    CheckInstanceChecksumResponse checkInstanceChecksum(1: CheckInstanceChecksumRequest request) throws (1:SessionDeniedExceptionThrift sde,
                                                                                                         2:shared.ServiceHavingBeenShutdownThrift shbsd),

    UpdateInstanceResponse updateInstance(1: UpdateInstanceRequest request) throws (1:SessionDeniedExceptionThrift sde,
                                                                                    2:shared.ServiceHavingBeenShutdownThrift shbsd),

    UpdateHeartbeatResponse updateHeartbeat(1: UpdateHeartbeatRequest request) throws (1:SessionDeniedExceptionThrift sde,
                                                                                       2:shared.ServiceHavingBeenShutdownThrift shbsd),

    BootstrapResponse bootstrap(1: BootstrapRequest request) throws (1:shared.ServiceHavingBeenShutdownThrift shbsd,
                                                                     2:BootstrapDeniedExceptionThrift bde),

    HeartBeatResponse heartBeat(1: HeartBeatRequest request) throws (1:shared.ServiceHavingBeenShutdownThrift shbsd),

    GetInstanceResponse getInstances(1: GetInstanceRequest request) throws (1:shared.ServiceHavingBeenShutdownThrift shbsd),

    TurnInstanceToFailedResponse turnInstanceToFailed(1: TurnInstanceToFailedRequest request) throws (1:shared.ServiceHavingBeenShutdownThrift shbsd,
                                                                                                       2:shared.InstanceNotExistsExceptionThrift inee,
                                                                                                       3:shared.InstanceHasFailedAleadyExceptionThrift ihfae),

    /**
     * DIH service bootstraps itself to another DIH service.
     *
     * Note: It is usually the two DIH service are in different data center. E.g one is of cluster in ShangHai,
     * the other one is of cluster in BeiJing.
     * @throws NotDihExceptionThrift if the endpoint specified in request is not of DIH service
     * @throws BootstrapDeniedExceptionThrift if the two DIH services are not in same region
     * @throws shared.ServiceHavingBeenShutdownThrift if target DIH service or current DIH service is going to be shutdown
     */
    BootstrapToResponse bootstrapTo(1: BootstrapToRequest request) throws (1:NotDihExceptionThrift nde,
                                                                         2:BootstrapDeniedExceptionThrift bde,
                                                                         3:shared.ServiceHavingBeenShutdownThrift shbsd),

    GetSyslogResponse getSyslog(1: GetSyslogRequest request),
}
